import 'package:logdash_frontend_mobile/features/orders/data/order_repository.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_request_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class OrdersViewModel {
  final OrderRepository _repository;

  OrdersViewModel(this._repository);

  final Signal<bool> isLoading = signal(false);
  final Signal<String?> errorMessage = signal(null);
  final Signal<List<OrderModel>> myOrders = signal([]);
  final Signal<OrderModel?> currentOrder = signal(null);

  Future<OrderModel?> placeOrder(OrderRequestModel request) async {
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.createOrder(request);
    isLoading.set(false);
    OrderModel? created;
    result.fold(
      (order) => created = order,
      (err) => errorMessage.set(_parseError(err)),
    );
    return created;
  }

  Future<void> loadMyOrders() async {
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.getMyOrders();
    isLoading.set(false);
    result.fold(
      (orders) => myOrders.set(orders),
      (err) => errorMessage.set(_parseError(err)),
    );
  }

  Future<void> loadOrder(int id) async {
    final result = await _repository.getOrder(id);
    result.fold(
      (order) => currentOrder.set(order),
      (err) => errorMessage.set(_parseError(err)),
    );
  }

  String _parseError(Exception err) =>
      err.toString().replaceFirst('Exception: ', '');
}
