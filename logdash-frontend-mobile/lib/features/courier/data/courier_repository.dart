import 'package:logdash_frontend_mobile/features/courier/data/courier_service.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_delivery_model.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_profile_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:result_dart/result_dart.dart';

class CourierRepository {
  final CourierService _service;

  CourierRepository(this._service);

  // ---- Perfil ----
  Future<CourierProfileModel?> getMyProfile() => _service.getMyProfile();

  AsyncResult<CourierProfileModel> selfRegister({
    required String name,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
  }) =>
      _service.selfRegister(
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
      );

  // ---- Entrega ativa ----
  Future<CourierDeliveryModel?> getMyActiveDelivery() =>
      _service.getMyActiveDelivery();

  // ---- Pedidos ----
  AsyncResult<List<OrderModel>> getOrdersReadyForPickup() =>
      _service.getOrdersReadyForPickup();

  // ---- Ações de entrega ----
  AsyncResult<CourierDeliveryModel> selfAssign(int orderId) =>
      _service.selfAssign(orderId);

  AsyncResult<CourierDeliveryModel> markPickedUp(int deliveryId) =>
      _service.markPickedUp(deliveryId);

  AsyncResult<CourierDeliveryModel> completeDelivery(int deliveryId) =>
      _service.completeDelivery(deliveryId);
}
