import 'package:auto_injector/auto_injector.dart';
import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/core/http/dio_client.dart';
import 'package:logdash_frontend_mobile/core/storage/secure_storage.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_service.dart';
import 'package:logdash_frontend_mobile/features/catalog/catalog_view_model.dart';
import 'package:logdash_frontend_mobile/features/catalog/data/catalog_repository.dart';
import 'package:logdash_frontend_mobile/features/catalog/data/catalog_service.dart';
import 'package:logdash_frontend_mobile/features/chat/chat_view_model.dart';
import 'package:logdash_frontend_mobile/features/chat/data/chat_repository.dart';
import 'package:logdash_frontend_mobile/features/chat/data/chat_service.dart';
import 'package:logdash_frontend_mobile/features/orders/data/order_repository.dart';
import 'package:logdash_frontend_mobile/features/orders/data/order_service.dart';
import 'package:logdash_frontend_mobile/features/orders/orders_view_model.dart';

final injector = AutoInjector();

void setupInjector() {
  // Auth (auth_repository deve ser registrado antes de Dio pois o interceptor o referencia)
  injector.addSingleton<SecureStorage>(SecureStorage.new);
  injector.addSingleton<AuthService>(AuthService.new);
  injector.addSingleton<AuthRepository>(
    () => AuthRepository(
      injector.get<AuthService>(),
      injector.get<SecureStorage>(),
    ),
  );

  // HTTP client com interceptor de autenticação
  injector.addSingleton<Dio>(
    () => createDioClient(injector.get<AuthRepository>()),
  );

  // Auth ViewModel
  injector.addSingleton<AuthViewModel>(
    () => AuthViewModel(injector.get<AuthRepository>()),
  );

  // Catalog
  injector.addSingleton<CatalogService>(
    () => CatalogService(injector.get<Dio>()),
  );
  injector.addSingleton<CatalogRepository>(
    () => CatalogRepository(injector.get<CatalogService>()),
  );
  injector.addSingleton<CatalogViewModel>(
    () => CatalogViewModel(injector.get<CatalogRepository>()),
  );

  // Orders
  injector.addSingleton<OrderService>(
    () => OrderService(injector.get<Dio>()),
  );
  injector.addSingleton<OrderRepository>(
    () => OrderRepository(injector.get<OrderService>()),
  );
  injector.addSingleton<OrdersViewModel>(
    () => OrdersViewModel(injector.get<OrderRepository>()),
  );

  // Chat
  injector.addSingleton<ChatService>(
    () => ChatService(injector.get<Dio>()),
  );
  injector.addSingleton<ChatRepository>(
    () => ChatRepository(injector.get<ChatService>()),
  );
  injector.addSingleton<ChatViewModel>(
    () => ChatViewModel(injector.get<ChatRepository>()),
  );

  injector.commit();
}
