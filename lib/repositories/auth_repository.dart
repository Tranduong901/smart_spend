import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    bool isFirebaseEnabled = true,
  })  : _firebaseAuth =
            isFirebaseEnabled ? (firebaseAuth ?? FirebaseAuth.instance) : null,
        _googleSignIn = googleSignIn,
        _isFirebaseEnabled = isFirebaseEnabled;

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final bool _isFirebaseEnabled;

  Stream<User?> authStateChanges() {
    if (!_isFirebaseEnabled || _firebaseAuth == null) {
      return Stream<User?>.value(null);
    }
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser => _firebaseAuth?.currentUser;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseEnabled();
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw AuthException(
        'Firebase chưa được cấu hình. Vui lòng cấu hình Firebase cho ứng dụng.',
      );
    }

    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } catch (_) {
      throw AuthException('Không thể đăng ký lúc này. Vui lòng thử lại.');
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseEnabled();
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw AuthException(
        'Firebase chưa được cấu hình. Vui lòng cấu hình Firebase cho ứng dụng.',
      );
    }

    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } catch (_) {
      throw AuthException('Không thể đăng nhập lúc này. Vui lòng thử lại.');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    _ensureFirebaseEnabled();
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw AuthException(
        'Firebase chưa được cấu hình. Vui lòng cấu hình Firebase cho ứng dụng.',
      );
    }

    try {
      final googleSignIn = _googleSignIn ?? GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Đăng nhập Google đã bị hủy.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Không thể đăng nhập bằng Google. Vui lòng kiểm tra mạng và thử lại.',
      );
    }
  }

  Future<void> signOut() async {
    final firebaseAuth = _firebaseAuth;
    if (!_isFirebaseEnabled || firebaseAuth == null) {
      return;
    }

    try {
      final googleSignIn = _googleSignIn;
      if (googleSignIn != null) {
        await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
      } else {
        await firebaseAuth.signOut();
      }
    } catch (_) {
      throw AuthException('Không thể đăng xuất lúc này.');
    }
  }

  void _ensureFirebaseEnabled() {
    if (!_isFirebaseEnabled) {
      throw AuthException(
        'Firebase chưa được cấu hình. Vui lòng cấu hình Firebase cho ứng dụng.',
      );
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'network-request-failed':
        return 'Mất kết nối mạng. Vui lòng kiểm tra Internet.';
      default:
        return 'Xác thực thất bại. Vui lòng thử lại.';
    }
  }
}
