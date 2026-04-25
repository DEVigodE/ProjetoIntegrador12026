import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/orders/data/delivery_location_service.dart';
import 'package:logdash_frontend_mobile/features/orders/orders_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

const _statusSteps = [
  'PENDING',
  'ACCEPTED',
  'PREPARING',
  'READY',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
];

const _statusLabels = {
  'PENDING': 'Aguardando confirmação',
  'ACCEPTED': 'Pedido aceito',
  'PREPARING': 'Em preparo',
  'READY': 'Pronto para entrega',
  'OUT_FOR_DELIVERY': 'Saiu para entrega',
  'DELIVERED': 'Entregue',
  'CANCELLED': 'Cancelado',
};

const _statusColors = {
  'PENDING': Colors.orange,
  'ACCEPTED': Colors.blue,
  'PREPARING': Colors.purple,
  'READY': Colors.teal,
  'OUT_FOR_DELIVERY': Colors.indigo,
  'DELIVERED': Colors.green,
  'CANCELLED': Colors.red,
};

class OrderTrackingPage extends StatefulWidget {
  final int orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final _viewModel = injector.get<OrdersViewModel>();
  final _authRepository = injector.get<AuthRepository>();

  Timer? _pollingTimer;
  final _locationService = DeliveryLocationService();
  final MapController _mapController = MapController();

  CourierLocationUpdate? _courierLocation;
  bool _locationServiceStarted = false;

  @override
  void initState() {
    super.initState();
    _viewModel.loadOrder(widget.orderId);
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      final order = _viewModel.currentOrder.value;
      if (order != null && order.isTerminal) {
        _pollingTimer?.cancel();
        return;
      }
      _viewModel.loadOrder(widget.orderId);
      _maybeStartLocationService();
    });

    _locationService.onLocationUpdate = (update) {
      if (mounted) {
        setState(() => _courierLocation = update);
        _mapController.move(
          LatLng(update.latitude, update.longitude),
          _mapController.camera.zoom,
        );
      }
    };

    // Tenta iniciar já na primeira carga
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartLocationService());
  }

  void _maybeStartLocationService() {
    final order = _viewModel.currentOrder.value;
    if (order == null) return;
    if (order.status != 'OUT_FOR_DELIVERY') return;
    if (_locationServiceStarted) return;

    final token = _authRepository.currentUser.value?.accessToken;
    if (token == null) return;

    _locationServiceStarted = true;
    _locationService.connect(
      orderId: widget.orderId,
      accessToken: token,
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _locationService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhar Pedido')),
      body: Watch((context) {
        final order = _viewModel.currentOrder.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Inicia o serviço de localização assim que o status chega
        if (order.status == 'OUT_FOR_DELIVERY' && !_locationServiceStarted) {
          _maybeStartLocationService();
        }

        final isCancelled = order.status == 'CANCELLED';
        final currentStepIndex =
            isCancelled ? -1 : _statusSteps.indexOf(order.status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho do pedido ───────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pedido #${order.id}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Total: R\$ ${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _statusColors[order.status] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _statusLabels[order.status] ?? order.status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Minimapa do entregador ────────────────────────────────
              if (order.status == 'OUT_FOR_DELIVERY') ...[
                _buildDeliveryMap(),
                const SizedBox(height: 16),
              ],

              // ── Timeline ou cancelamento ──────────────────────────────
              if (isCancelled)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pedido Cancelado',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        if (order.rejectedReason != null) ...[
                          const SizedBox(height: 4),
                          Text('Motivo: ${order.rejectedReason}'),
                        ],
                      ],
                    ),
                  ),
                )
              else ...[
                const Text('Acompanhamento',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._statusSteps.asMap().entries.map((entry) {
                  final stepIndex = entry.key;
                  final stepStatus = entry.value;
                  final isDone = stepIndex <= currentStepIndex;
                  final isCurrent = stepIndex == currentStepIndex;

                  return Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? Colors.green
                                  : Colors.grey[300],
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.circle,
                              color: isDone
                                  ? Colors.white
                                  : Colors.grey[400],
                              size: 16,
                            ),
                          ),
                          if (stepIndex < _statusSteps.length - 1)
                            Container(
                              width: 2,
                              height: 32,
                              color: stepIndex < currentStepIndex
                                  ? Colors.green
                                  : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Text(
                          _statusLabels[stepStatus] ?? stepStatus,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? Colors.green
                                : Colors.grey[600],
                            fontSize: isCurrent ? 15 : 13,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // ── Itens ─────────────────────────────────────────────────
              const Text('Itens do pedido',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child:
                              Text('${item.quantity}x ${item.productName}')),
                      Text('R\$ ${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/chat/${widget.orderId}'),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Chat com suporte'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDeliveryMap() {
    final loc = _courierLocation;
    final center = loc != null
        ? LatLng(loc.latitude, loc.longitude)
        : const LatLng(-23.5505, -46.6333); // São Paulo como default

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.delivery_dining,
                    color: Colors.indigo[400], size: 20),
                const SizedBox(width: 8),
                const Text('Entregador a caminho',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                if (loc == null)
                  const Row(
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                      SizedBox(width: 6),
                      Text('Aguardando sinal...',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Ao vivo',
                          style: TextStyle(
                              fontSize: 11, color: Colors.green)),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.logdash.mobile',
                ),
                if (loc != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(loc.latitude, loc.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.indigo,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (loc != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Atualizado às ${_formatTime(loc.timestamp)}',
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String isoTimestamp) {
    try {
      final dt = DateTime.parse(isoTimestamp).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      final s = dt.second.toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return isoTimestamp;
    }
  }
}
