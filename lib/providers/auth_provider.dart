import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_spend/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final credential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
    });
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final credential = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
    });
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      final credential = await _authRepository.signInWithGoogle();
      _currentUser = credential.user;
    });
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Đăng xuất thất bại. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Đã xảy ra lỗi xác thực. Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
