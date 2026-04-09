import 'package:logdash_frontend_mobile/features/orders/data/order_service.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_request_model.dart';
import 'package:result_dart/result_dart.dart';

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  AsyncResult<OrderModel> createOrder(OrderRequestModel request) =>
      _service.createOrder(request);

  AsyncResult<List<OrderModel>> getMyOrders() => _service.getMyOrders();

  AsyncResult<OrderModel> getOrder(int id) => _service.getOrder(id);
}
