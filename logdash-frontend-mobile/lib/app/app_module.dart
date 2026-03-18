import 'package:auto_injector/auto_injector.dart';
import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/core/http/dio_client.dart';
import 'package:logdash_frontend_mobile/core/storage/secure_storage.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_service.dart';

final injector = AutoInjector();

void setupInjector() {
  injector.addSingleton<Dio>(createDioClient);
  injector.addSingleton<SecureStorage>(SecureStorage.new);
  injector.addSingleton<AuthService>(AuthService.new);
  injector.addSingleton<AuthRepository>(
    () => AuthRepository(
      injector.get<AuthService>(),
      injector.get<SecureStorage>(),
    ),
  );
  injector.addSingleton<AuthViewModel>(
    () => AuthViewModel(injector.get<AuthRepository>()),
  );
  injector.commit();
}
