import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logdash_frontend_mobile/core/config/app_config.dart';
import 'package:logdash_frontend_mobile/features/courier/domain/location_update_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Serviço responsável por:
///  1. Capturar localização GPS do entregador em intervalos regulares.
///  2. Publicar cada atualização via STOMP em /app/delivery/{id}/location.
///  3. Armazenar localmente quando offline e reenviar ao reconectar.
class CourierLocationService {
  static const _stompUrl = AppConfig.stompUrl;
  static const _offlineQueueKey = 'courier_offline_location_queue';
  static const _intervalSeconds = 3;

  StompClient? _stompClient;
  Timer? _locationTimer;
  StreamSubscription? _connectivitySub;

  String? _courierId;
  int? _deliveryId;
  int? _orderId;
  String? _currentStatus;
  String? _accessToken;

  bool _stompConnected = false;

  /// Inicia o rastreamento GPS e publica via STOMP.
  Future<void> start({
    required String courierId,
    required int deliveryId,
    required int orderId,
    required String deliveryStatus,
    required String accessToken,
  }) async {
    dev.log('[LocationService] start — courierId=$courierId, deliveryId=$deliveryId, status=$deliveryStatus', name: 'Courier');
    _courierId = courierId;
    _deliveryId = deliveryId;
    _orderId = orderId;
    _currentStatus = deliveryStatus;
    _accessToken = accessToken;

    final hasPermission = await _requestLocationPermission();
    dev.log('[LocationService] start — permissão GPS: $hasPermission', name: 'Courier');
    if (!hasPermission) {
      dev.log('[LocationService] start — ABORTADO: sem permissão de localização', name: 'Courier', level: 900);
      return;
    }

    _connectStomp();
    _startLocationTimer();
    _watchConnectivity();
    dev.log('[LocationService] start — timer GPS e STOMP iniciados', name: 'Courier');
  }

  /// Atualiza o status da entrega sem parar o rastreamento.
  void updateStatus(String newStatus) {
    dev.log('[LocationService] updateStatus — $newStatus', name: 'Courier');
    _currentStatus = newStatus;
  }

  /// Para o rastreamento e desconecta do STOMP.
  void stop() {
    dev.log('[LocationService] stop — encerrando GPS e STOMP', name: 'Courier');
    _locationTimer?.cancel();
    _connectivitySub?.cancel();
    _stompClient?.deactivate();
    _stompClient = null;
    _stompConnected = false;
  }

  // ---- GPS ----

  Future<bool> _requestLocationPermission() async {
    dev.log('[LocationService] _requestLocationPermission — verificando serviço GPS', name: 'Courier');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    dev.log('[LocationService] _requestLocationPermission — serviceEnabled=$serviceEnabled', name: 'Courier');
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    dev.log('[LocationService] _requestLocationPermission — permissão atual=$permission', name: 'Courier');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      dev.log('[LocationService] _requestLocationPermission — após solicitar=$permission', name: 'Courier');
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void _startLocationTimer() {
    dev.log('[LocationService] _startLocationTimer — intervalo=${_intervalSeconds}s', name: 'Courier');
    _locationTimer?.cancel();
    _locationTimer =
        Timer.periodic(const Duration(seconds: _intervalSeconds), (_) async {
      try {
        dev.log('[LocationService] timer — obtendo posição GPS...', name: 'Courier');
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        );
        dev.log('[LocationService] timer — posição: lat=${position.latitude}, lng=${position.longitude}', name: 'Courier');
        await _publishOrQueue(position.latitude, position.longitude);
      } catch (e) {
        dev.log('[LocationService] timer — ERRO ao obter GPS: $e', name: 'Courier', level: 900);
      }
    });
  }

  // ---- STOMP ----

  void _connectStomp() {
    dev.log('[LocationService] _connectStomp — conectando em $_stompUrl', name: 'Courier');
    _stompClient = StompClient(
      config: StompConfig(
        url: _stompUrl,
        onConnect: _onStompConnected,
        onDisconnect: (frame) {
          dev.log('[LocationService] STOMP desconectado', name: 'Courier', level: 800);
          _stompConnected = false;
        },
        onStompError: (frame) {
          dev.log('[LocationService] STOMP erro: ${frame.body}', name: 'Courier', level: 900);
          _stompConnected = false;
        },
        onWebSocketError: (error) {
          dev.log('[LocationService] WebSocket erro: $error', name: 'Courier', level: 900);
          _stompConnected = false;
        },
        connectionTimeout: const Duration(seconds: 10),
        stompConnectHeaders: {
          'Authorization': 'Bearer $_accessToken',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $_accessToken',
        },
      ),
    );
    _stompClient!.activate();
  }

  void _onStompConnected(StompFrame frame) {
    dev.log('[LocationService] STOMP conectado com sucesso', name: 'Courier');
    _stompConnected = true;
    _flushOfflineQueue();
  }

  Future<void> _publishOrQueue(double lat, double lng) async {
    final update = LocationUpdateModel(
      courierId: _courierId ?? '',
      deliveryId: _deliveryId ?? 0,
      orderId: _orderId ?? 0,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      latitude: lat,
      longitude: lng,
      status: _currentStatus ?? 'a_caminho',
    );

    if (_stompConnected && _stompClient != null) {
      dev.log('[LocationService] _publishOrQueue — enviando via STOMP (lat=$lat, lng=$lng, status=${update.status})', name: 'Courier');
      _sendStomp(update);
    } else {
      dev.log('[LocationService] _publishOrQueue — STOMP offline, enfileirando localmente (stompConnected=$_stompConnected)', name: 'Courier', level: 800);
      await _enqueueOffline(update);
    }
  }

  void _sendStomp(LocationUpdateModel update) {
    _stompClient?.send(
      destination: '/app/delivery/${update.deliveryId}/location',
      body: jsonEncode(update.toJson()),
    );
  }

  // ---- Fila offline (SharedPreferences) ----

  Future<void> _enqueueOffline(LocationUpdateModel update) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_offlineQueueKey) ?? [];
    raw.add(jsonEncode(update.toJson()));
    // Limita fila a 200 entradas para não consumir muita memória
    if (raw.length > 200) raw.removeAt(0);
    await prefs.setStringList(_offlineQueueKey, raw);
  }

  Future<void> _flushOfflineQueue() async {
    if (!_stompConnected) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_offlineQueueKey) ?? [];
    if (raw.isEmpty) return;

    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final update = LocationUpdateModel(
          courierId: map['courierId'] as String,
          deliveryId: map['deliveryId'] as int,
          orderId: map['orderId'] as int,
          timestamp: map['timestamp'] as String,
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          status: map['status'] as String,
        );
        _sendStomp(update);
      } catch (_) {
        // ignora item corrompido
      }
    }
    await prefs.remove(_offlineQueueKey);
  }

  // ---- Conectividade ----

  void _watchConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && !_stompConnected) {
        _connectStomp();
      }
    });
  }
}
