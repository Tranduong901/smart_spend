import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_spend/models/transaction.dart' as model;
import 'package:smart_spend/repositories/local_repository.dart';

class SyncException implements Exception {
  SyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CloudSyncRepository {
  CloudSyncRepository({
    required LocalRepository localRepository,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
    bool isFirebaseEnabled = true,
  })  : _localRepository = localRepository,
        _firebaseAuth =
            isFirebaseEnabled ? (firebaseAuth ?? FirebaseAuth.instance) : null,
        _firestore = isFirebaseEnabled
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _connectivity = connectivity ?? Connectivity(),
        _isFirebaseEnabled = isFirebaseEnabled;

  final LocalRepository _localRepository;
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  final Connectivity _connectivity;
  final bool _isFirebaseEnabled;

  Future<void> syncFromHiveToFirebase() async {
    if (!_isFirebaseEnabled) {
      throw SyncException('Firebase chưa được cấu hình để đồng bộ dữ liệu.');
    }

    if (!await _hasNetworkConnection()) {
      throw SyncException(
          'Không có kết nối mạng. Dữ liệu sẽ được đồng bộ sau.');
    }

    final firebaseAuth = _firebaseAuth;
    final firestore = _firestore;
    if (firebaseAuth == null || firestore == null) {
      throw SyncException('Firebase chưa được cấu hình để đồng bộ dữ liệu.');
    }

    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw SyncException('Vui lòng đăng nhập để đồng bộ dữ liệu lên đám mây.');
    }

    try {
      final localTransactions = await _localRepository.readTransactions();
      final userRef = firestore.collection('users').doc(user.uid);
      final batch = firestore.batch();

      for (final transaction in localTransactions) {
        final docRef = userRef.collection('transactions').doc(transaction.id);
        batch.set(docRef, _toMap(transaction), SetOptions(merge: true));
      }

      batch.set(
          userRef,
          {
            'lastSyncedAt': FieldValue.serverTimestamp(),
            'transactionCount': localTransactions.length,
          },
          SetOptions(merge: true));

      await batch.commit();
    } on FirebaseException catch (error) {
      if (error.code == 'unavailable') {
        throw SyncException(
          'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.',
        );
      }
      throw SyncException(
          'Đồng bộ dữ liệu thất bại: ${error.message ?? error.code}');
    } catch (_) {
      throw SyncException('Đồng bộ dữ liệu thất bại. Vui lòng thử lại.');
    }
  }

  Future<bool> _hasNetworkConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.any((item) => item != ConnectivityResult.none);
  }

  Map<String, dynamic> _toMap(model.Transaction transaction) {
    return {
      'id': transaction.id,
      'amount': transaction.amount,
      'category': transaction.category.name,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'imagePath': transaction.imagePath,
      'isIncome': transaction.isIncome,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
