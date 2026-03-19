import 'package:flutter/foundation.dart';
import 'package:smart_spend/models/transaction.dart';
import 'package:smart_spend/repositories/cloud_sync_repository.dart';
import 'package:smart_spend/repositories/local_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({
    required LocalRepository localRepository,
    CloudSyncRepository? cloudSyncRepository,
    List<Transaction> initialTransactions = const [],
  })  : _localRepository = localRepository,
        _cloudSyncRepository = cloudSyncRepository,
        _transactions = List<Transaction>.from(initialTransactions);

  final LocalRepository _localRepository;
  final CloudSyncRepository? _cloudSyncRepository;
  final List<Transaction> _transactions;
  String? _syncErrorMessage;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String? get syncErrorMessage => _syncErrorMessage;

  Future<void> addTransaction(Transaction transaction) async {
    final savedTransaction =
        await _localRepository.createTransaction(transaction);
    _transactions.insert(0, savedTransaction);
    await _syncHiveToCloudSilently();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _localRepository.deleteTransaction(id);
    _transactions.removeWhere((transaction) => transaction.id == id);
    await _syncHiveToCloudSilently();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final updatedTransaction = await _localRepository.updateTransaction(
      transaction,
    );
    final index = _transactions.indexWhere((item) => item.id == transaction.id);

    if (index < 0) {
      return;
    }

    _transactions[index] = updatedTransaction;
    await _syncHiveToCloudSilently();
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    final loadedTransactions = await _localRepository.readTransactions();
    _transactions
      ..clear()
      ..addAll(loadedTransactions);
    notifyListeners();
  }

  Future<void> syncHiveToCloud() async {
    if (_cloudSyncRepository == null) {
      _syncErrorMessage = 'Chưa có cấu hình đồng bộ đám mây.';
      notifyListeners();
      return;
    }

    try {
      await _cloudSyncRepository.syncFromHiveToFirebase();
      _syncErrorMessage = null;
    } on SyncException catch (error) {
      _syncErrorMessage = error.message;
    } catch (_) {
      _syncErrorMessage = 'Đồng bộ dữ liệu thất bại. Vui lòng thử lại.';
    }

    notifyListeners();
  }

  void clearSyncError() {
    _syncErrorMessage = null;
    notifyListeners();
  }

  double calculateTotalBalance({double initialBalance = 15000000}) {
    final totalIncome = _transactions
        .where((transaction) => transaction.isIncome)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final totalExpense = _transactions
        .where((transaction) => !transaction.isIncome)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    return initialBalance + totalIncome - totalExpense;
  }

  List<Transaction> filterByCategory(ExpenseCategory category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .toList();
  }

  Future<void> _syncHiveToCloudSilently() async {
    if (_cloudSyncRepository == null) {
      return;
    }

    try {
      await _cloudSyncRepository.syncFromHiveToFirebase();
      _syncErrorMessage = null;
    } on SyncException catch (error) {
      _syncErrorMessage = error.message;
    } catch (_) {
      _syncErrorMessage = 'Đồng bộ dữ liệu thất bại. Vui lòng thử lại.';
    }
  }
}
