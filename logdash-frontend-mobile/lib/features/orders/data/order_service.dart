import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_request_model.dart';
import 'package:result_dart/result_dart.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  AsyncResult<OrderModel> createOrder(OrderRequestModel request) async {
    try {
      final response =
          await _dio.post('/api/orders', data: request.toJson());
      return Success(OrderModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao criar pedido';
      return Failure(Exception(msg.toString()));
    }
  }

  AsyncResult<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get('/api/orders/my');
      final content = response.data['content'] as List<dynamic>;
      final list = content
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao carregar pedidos';
      return Failure(Exception(msg.toString()));
    }
  }

  AsyncResult<OrderModel> getOrder(int id) async {
    try {
      final response = await _dio.get('/api/orders/$id');
      final dynamic raw = response.data;
      final Map<String, dynamic> data;
      if (raw is List) {
        data = raw.first as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic> && raw.containsKey('content')) {
        data = (raw['content'] as List<dynamic>).first as Map<String, dynamic>;
      } else {
        data = raw as Map<String, dynamic>;
      }
      return Success(OrderModel.fromJson(data));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao carregar pedido';
      return Failure(Exception(msg.toString()));
    }
  }
}
