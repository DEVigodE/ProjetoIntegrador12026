import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/core/config/app_config.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

Dio createDioClient(AuthRepository authRepository) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = authRepository.currentUser.value?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await authRepository.logout();
        }
        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  return dio;
}
