import 'dart:developer' as dev;

import 'package:logdash_frontend_mobile/features/auth/domain/user_model.dart';
import 'package:logdash_frontend_mobile/features/courier/data/courier_location_service.dart';
import 'package:logdash_frontend_mobile/features/courier/data/courier_repository.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_delivery_model.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/courier_profile_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CourierViewModel {
  final CourierRepository _repository;
  final CourierLocationService _locationService;

  CourierViewModel(this._repository, this._locationService);

  final Signal<bool> isLoading = signal(false);
  final Signal<String?> errorMessage = signal(null);
  final Signal<CourierProfileModel?> profile = signal(null);
  final Signal<bool> needsProfileSetup = signal(false);
  final Signal<CourierDeliveryModel?> activeDelivery = signal(null);
  final Signal<List<OrderModel>> availableOrders = signal([]);
  final Signal<bool> isTracking = signal(false);

  /// Verifica se o entregador tem perfil cadastrado e carrega dados iniciais.
  Future<void> loadInitialData() async {
    isLoading.set(true);
    errorMessage.set(null);

    // 1. Verifica perfil
    final courierProfile = await _repository.getMyProfile();
    profile.set(courierProfile);

    if (courierProfile == null) {
      needsProfileSetup.set(true);
      isLoading.set(false);
      return;
    }
    needsProfileSetup.set(false);

    // 2. Carrega entrega ativa e pedidos disponíveis em paralelo
    final deliveryFuture = _repository.getMyActiveDelivery();
    final ordersFuture = _repository.getOrdersReadyForPickup();

    final delivery = await deliveryFuture;
    activeDelivery.set(delivery);

    final ordersResult = await ordersFuture;
    ordersResult.fold(
      (orders) => availableOrders.set(orders),
      (_) => availableOrders.set([]),
    );

    isLoading.set(false);
  }

  /// Cria o perfil do entregador (chamado na tela de setup).
  Future<bool> registerProfile({
    required String name,
    required String phone,
    required String vehicleType,
    required String vehiclePlate,
  }) async {
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.selfRegister(
      name: name,
      phone: phone,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
    );
    isLoading.set(false);
    return result.fold(
      (p) {
        profile.set(p);
        needsProfileSetup.set(false);
        return true;
      },
      (err) {
        errorMessage.set(_parseError(err));
        return false;
      },
    );
  }

  /// Entregador aceita um pedido disponível (auto-atribuição).
  Future<bool> acceptOrder(int orderId) async {
    dev.log('[CourierViewModel] acceptOrder — orderId=$orderId', name: 'Courier');
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.selfAssign(orderId);
    isLoading.set(false);
    return result.fold(
      (delivery) {
        dev.log('[CourierViewModel] acceptOrder — sucesso, deliveryId=${delivery.id}', name: 'Courier');
        activeDelivery.set(delivery);
        availableOrders.set(
          availableOrders.value.where((o) => o.id != orderId).toList(),
        );
        return true;
      },
      (err) {
        dev.log('[CourierViewModel] acceptOrder — ERRO: $err', name: 'Courier', level: 900);
        errorMessage.set(_parseError(err));
        return false;
      },
    );
  }

  /// Entregador confirma retirada no estabelecimento.
  Future<bool> markPickedUp() async {
    final delivery = activeDelivery.value;
    dev.log('[CourierViewModel] markPickedUp — deliveryId=${delivery?.id}', name: 'Courier');
    if (delivery == null) return false;
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.markPickedUp(delivery.id);
    isLoading.set(false);
    return result.fold(
      (updated) {
        dev.log('[CourierViewModel] markPickedUp — sucesso, status=${updated.status}', name: 'Courier');
        activeDelivery.set(updated);
        _locationService.updateStatus('pedido_retirado');
        return true;
      },
      (err) {
        dev.log('[CourierViewModel] markPickedUp — ERRO: $err', name: 'Courier', level: 900);
        errorMessage.set(_parseError(err));
        return false;
      },
    );
  }

  /// Entregador confirma entrega concluída ao cliente.
  Future<bool> completeDelivery() async {
    final delivery = activeDelivery.value;
    dev.log('[CourierViewModel] completeDelivery — deliveryId=${delivery?.id}', name: 'Courier');
    if (delivery == null) return false;
    isLoading.set(true);
    errorMessage.set(null);
    final result = await _repository.completeDelivery(delivery.id);
    isLoading.set(false);
    return result.fold(
      (updated) {
        dev.log('[CourierViewModel] completeDelivery — sucesso, status=${updated.status}', name: 'Courier');
        activeDelivery.set(updated);
        stopTracking();
        return true;
      },
      (err) {
        dev.log('[CourierViewModel] completeDelivery — ERRO: $err', name: 'Courier', level: 900);
        errorMessage.set(_parseError(err));
        return false;
      },
    );
  }

  /// Inicia rastreamento GPS + publicação STOMP.
  Future<void> startTracking(UserModel user, String deliveryStatus) async {
    final delivery = activeDelivery.value;
    dev.log('[CourierViewModel] startTracking — userId=${user.id}, deliveryId=${delivery?.id}, status=$deliveryStatus', name: 'Courier');
    if (delivery == null) {
      dev.log('[CourierViewModel] startTracking — ABORTADO: activeDelivery é nulo', name: 'Courier', level: 900);
      return;
    }
    await _locationService.start(
      courierId: user.id,
      deliveryId: delivery.id,
      orderId: delivery.orderId,
      deliveryStatus: deliveryStatus,
      accessToken: user.accessToken,
    );
    isTracking.set(true);
    dev.log('[CourierViewModel] startTracking — concluído', name: 'Courier');
  }

  /// Atualiza o status enviado no payload de localização.
  void updateTrackingStatus(String status) {
    dev.log('[CourierViewModel] updateTrackingStatus — status=$status', name: 'Courier');
    _locationService.updateStatus(status);
  }

  /// Para o rastreamento GPS.
  void stopTracking() {
    dev.log('[CourierViewModel] stopTracking', name: 'Courier');
    _locationService.stop();
    isTracking.set(false);
  }

  String _parseError(Exception err) =>
      err.toString().replaceFirst('Exception: ', '');
}
