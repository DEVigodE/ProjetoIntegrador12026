import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:logdash_frontend_mobile/core/storage/secure_storage.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_service.dart';
import 'package:logdash_frontend_mobile/features/auth/domain/user_model.dart';

class AuthRepository extends ChangeNotifier {
  final AuthService _service;
  final SecureStorage _storage;

  final Signal<UserModel?> currentUser = signal(null);

  AuthRepository(this._service, this._storage);

  bool get isAuthenticated => currentUser.value != null;

  Future<void> restoreSession() async {
    final token = await _storage.getAccessToken();
    final refresh = await _storage.getRefreshToken();
    if (token != null && refresh != null) {
      try {
        _setUser(UserModel.fromTokens(accessToken: token, refreshToken: refresh));
      } catch (_) {
        await _storage.clearTokens();
      }
    }
  }

  AsyncResult<UserModel> login(String username, String password) async {
    final result = await _service.login(username, password);
    if (result.isError()) {
      return Failure(result.exceptionOrNull()!);
    }
    final data = result.getOrThrow();
    final user = UserModel.fromTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    await _storage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    _setUser(user);
    return Success(user);
  }

  AsyncResult<Unit> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final result = await _service.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    if (result.isError()) {
      return Failure(result.exceptionOrNull()!);
    }
    return Success(unit);
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    _setUser(null);
  }

  void _setUser(UserModel? user) {
    currentUser.set(user);
    notifyListeners();
  }
}
