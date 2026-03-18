import 'package:signals_flutter/signals_flutter.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/auth/domain/user_model.dart';

class AuthViewModel {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  Signal<UserModel?> get currentUser => _repository.currentUser;
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> errorMessage = signal(null);

  Future<bool> login(String username, String password) async {
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.login(username, password);
    isLoading.set(false);
    var success = false;
    result.fold(
      (_) => success = true,
      (err) => errorMessage.set(_parseError(err)),
    );
    return success;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    isLoading.set(false);
    var success = false;
    result.fold(
      (_) => success = true,
      (err) => errorMessage.set(_parseError(err)),
    );
    return success;
  }

  Future<void> logout() => _repository.logout();

  String _parseError(Exception err) =>
      err.toString().replaceFirst('Exception: ', '');
}
