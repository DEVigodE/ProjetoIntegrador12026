import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:logdash_frontend_mobile/core/config/app_config.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Payload de localização recebido do backend via STOMP.
class CourierLocationUpdate {
  final String courierId;
  final int deliveryId;
  final int orderId;
  final double latitude;
  final double longitude;
  final String status;
  final String timestamp;

  const CourierLocationUpdate({
    required this.courierId,
    required this.deliveryId,
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.timestamp,
  });

  factory CourierLocationUpdate.fromJson(Map<String, dynamic> json) {
    return CourierLocationUpdate(
      courierId: json['courierId'] as String? ?? '',
      deliveryId: (json['deliveryId'] as num?)?.toInt() ?? 0,
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

/// Serviço responsável por receber atualizações de localização do entregador
/// via STOMP no tópico /topic/order/{orderId}/location.
///
/// Uso:
///   final service = DeliveryLocationService();
///   service.onLocationUpdate = (loc) { ... };
///   await service.connect(orderId: 123, accessToken: token);
///   // ...
///   service.disconnect();
class DeliveryLocationService {
  static const _stompUrl = AppConfig.stompUrl;

  StompClient? _client;
  StompUnsubscribe? _subscription;

  void Function(CourierLocationUpdate)? onLocationUpdate;

  Future<void> connect({
    required int orderId,
    required String accessToken,
  }) async {
    dev.log('[DeliveryLocationService] connect — orderId=$orderId', name: 'Customer');

    _client = StompClient(
      config: StompConfig(
        url: _stompUrl,
        onConnect: (frame) => _onConnected(frame, orderId),
        onDisconnect: (_) {
          dev.log('[DeliveryLocationService] STOMP desconectado', name: 'Customer');
        },
        onStompError: (frame) {
          dev.log('[DeliveryLocationService] STOMP erro: ${frame.body}', name: 'Customer', level: 900);
        },
        onWebSocketError: (error) {
          dev.log('[DeliveryLocationService] WebSocket erro: $error', name: 'Customer', level: 900);
        },
        connectionTimeout: const Duration(seconds: 10),
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    _client!.activate();
  }

  void _onConnected(StompFrame frame, int orderId) {
    dev.log('[DeliveryLocationService] conectado — subscrevendo /topic/order/$orderId/location', name: 'Customer');
    _subscription = _client!.subscribe(
      destination: '/topic/order/$orderId/location',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final update = CourierLocationUpdate.fromJson(json);
          dev.log('[DeliveryLocationService] localização recebida: lat=${update.latitude}, lng=${update.longitude}', name: 'Customer');
          onLocationUpdate?.call(update);
        } catch (e) {
          dev.log('[DeliveryLocationService] erro ao parsear payload: $e', name: 'Customer', level: 900);
        }
      },
    );
  }

  void disconnect() {
    dev.log('[DeliveryLocationService] disconnect', name: 'Customer');
    _subscription?.call();
    _subscription = null;
    _client?.deactivate();
    _client = null;
  }
}
