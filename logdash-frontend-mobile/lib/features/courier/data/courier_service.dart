import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_delivery_model.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_profile_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:result_dart/result_dart.dart';

class CourierService {
  final Dio _dio;

  CourierService(this._dio);

  // ---- Perfil do entregador ----

  /// Verifica se o entregador autenticado já possui perfil no sistema.
  /// Retorna null quando o perfil ainda não existe (HTTP 404).
  Future<CourierProfileModel?> getMyProfile() async {
    try {
      final response = await _dio.get('/api/couriers/me');
      return CourierProfileModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      return null;
    }
  }

  /// Cria o perfil do entregador (auto-cadastro).
  /// Retorna o perfil criado (ou existente se já cadastrado).
  AsyncResult<CourierProfileModel> selfRegister({
    required String name,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
  }) async {
    try {
      final response = await _dio.post(
        '/api/couriers/me',
        data: {
          'name': name,
          'phone': phone,
          'vehicleType': vehicleType,
          'vehiclePlate': vehiclePlate,
        },
      );
      return Success(CourierProfileModel.fromJson(
          response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Erro ao cadastrar perfil';
      return Failure(Exception(msg.toString()));
    }
  }

  // ---- Entrega ativa ----

  /// Retorna a entrega ativa do entregador autenticado, ou null se não houver.
  Future<CourierDeliveryModel?> getMyActiveDelivery() async {
    try {
      final response = await _dio.get('/api/deliveries/my-active');
      if (response.statusCode == 204 || response.data == null) return null;
      return CourierDeliveryModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
        return null;
      }
      return null;
    }
  }

  // ---- Pedidos disponíveis ----

  /// Lista pedidos prontos para retirada (status READY).
  AsyncResult<List<OrderModel>> getOrdersReadyForPickup() async {
    try {
      final response = await _dio.get('/api/orders/ready-for-pickup');
      final content = response.data['content'] as List<dynamic>;
      final list = content
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          'Erro ao carregar pedidos disponíveis';
      return Failure(Exception(msg.toString()));
    }
  }

  // ---- Ações de entrega ----

  /// Entregador aceita (auto-atribui) um pedido.
  AsyncResult<CourierDeliveryModel> selfAssign(int orderId) async {
    try {
      final response = await _dio.post(
        '/api/deliveries/self-assign',
        data: {'orderId': orderId},
      );
      return Success(
          CourierDeliveryModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao aceitar pedido';
      return Failure(Exception(msg.toString()));
    }
  }

  /// Entregador confirma retirada do pedido no estabelecimento.
  AsyncResult<CourierDeliveryModel> markPickedUp(int deliveryId) async {
    try {
      final response =
          await _dio.patch('/api/deliveries/$deliveryId/pickup');
      return Success(
          CourierDeliveryModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Erro ao confirmar retirada';
      return Failure(Exception(msg.toString()));
    }
  }

  /// Entregador confirma entrega concluída ao cliente.
  AsyncResult<CourierDeliveryModel> completeDelivery(int deliveryId) async {
    try {
      final response =
          await _dio.patch('/api/deliveries/$deliveryId/complete');
      return Success(
          CourierDeliveryModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Erro ao confirmar entrega';
      return Failure(Exception(msg.toString()));
    }
  }
}
