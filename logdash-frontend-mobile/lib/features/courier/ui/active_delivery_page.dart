import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/courier/courier_view_model.dart';
import 'package:logdash_frontend_mobile/features/orders/data/order_repository.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Status internos do entregador — mapeados sobre o DeliveryStatus do backend.
enum _CourierStep {
  headingToStore, // ASSIGNED: a caminho do estabelecimento
  atStore, // ASSIGNED: chegou ao estabelecimento
  pickedUp, // PICKED_UP: pedido retirado
  headingToClient, // PICKED_UP: a caminho do cliente
  atDestination, // PICKED_UP: chegou ao destino
  delivered, // DELIVERED: entrega concluída
}

const _stepLabels = {
  _CourierStep.headingToStore: 'A caminho do estabelecimento',
  _CourierStep.atStore: 'Chegou ao estabelecimento',
  _CourierStep.pickedUp: 'Pedido retirado',
  _CourierStep.headingToClient: 'A caminho do cliente',
  _CourierStep.atDestination: 'Chegou ao destino',
  _CourierStep.delivered: 'Entrega concluída',
};

const _stepStatusPayload = {
  _CourierStep.headingToStore: 'a_caminho_do_estabelecimento',
  _CourierStep.atStore: 'chegou_ao_estabelecimento',
  _CourierStep.pickedUp: 'pedido_retirado',
  _CourierStep.headingToClient: 'a_caminho_do_cliente',
  _CourierStep.atDestination: 'chegou_ao_destino',
  _CourierStep.delivered: 'entrega_concluida',
};

class ActiveDeliveryPage extends StatefulWidget {
  final int deliveryId;

  const ActiveDeliveryPage({super.key, required this.deliveryId});

  @override
  State<ActiveDeliveryPage> createState() => _ActiveDeliveryPageState();
}

class _ActiveDeliveryPageState extends State<ActiveDeliveryPage> {
  final _viewModel = injector.get<CourierViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();
  final _orderRepository = injector.get<OrderRepository>();

  _CourierStep _currentStep = _CourierStep.headingToStore;
  OrderModel? _order;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    dev.log('[ActiveDeliveryPage] initState — deliveryId=${widget.deliveryId}', name: 'Courier');
    _syncStep();
    _loadOrder();
    _startTracking();
    // Atualiza dados a cada 20s
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _viewModel.loadInitialData(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _syncStep() {
    final delivery = _viewModel.activeDelivery.value;
    dev.log('[ActiveDeliveryPage] _syncStep — delivery=${delivery?.id}, status=${delivery?.status}', name: 'Courier');
    if (delivery == null) return;
    if (delivery.status == 'PICKED_UP') {
      dev.log('[ActiveDeliveryPage] _syncStep → headingToClient', name: 'Courier');
      setState(() => _currentStep = _CourierStep.headingToClient);
    } else if (delivery.status == 'DELIVERED') {
      dev.log('[ActiveDeliveryPage] _syncStep → delivered', name: 'Courier');
      setState(() => _currentStep = _CourierStep.delivered);
    }
  }

  Future<void> _loadOrder() async {
    final delivery = _viewModel.activeDelivery.value;
    dev.log('[ActiveDeliveryPage] _loadOrder — orderId=${delivery?.orderId}', name: 'Courier');
    if (delivery == null) return;
    final result = await _orderRepository.getOrder(delivery.orderId);
    result.fold(
      (order) {
        dev.log('[ActiveDeliveryPage] _loadOrder — sucesso, order.id=${order.id}', name: 'Courier');
        setState(() => _order = order);
      },
      (err) => dev.log('[ActiveDeliveryPage] _loadOrder — ERRO: $err', name: 'Courier', level: 900),
    );
  }

  Future<void> _startTracking() async {
    final user = _authViewModel.currentUser.value;
    dev.log('[ActiveDeliveryPage] _startTracking — user=${user?.id}, step=$_currentStep', name: 'Courier');
    if (user == null) {
      dev.log('[ActiveDeliveryPage] _startTracking — ABORTADO: usuário nulo', name: 'Courier', level: 900);
      return;
    }
    await _viewModel.startTracking(
      user,
      _stepStatusPayload[_currentStep] ?? 'a_caminho',
    );
    dev.log('[ActiveDeliveryPage] _startTracking — concluído, isTracking=${_viewModel.isTracking.value}', name: 'Courier');
  }

  void _advanceStep() {
    final nextStep = _nextStep(_currentStep);
    dev.log('[ActiveDeliveryPage] _advanceStep — de=$_currentStep para=$nextStep', name: 'Courier');
    if (nextStep == null) return;
    setState(() => _currentStep = nextStep);
    _viewModel.updateTrackingStatus(
        _stepStatusPayload[_currentStep] ?? 'a_caminho');
  }

  _CourierStep? _nextStep(_CourierStep step) {
    switch (step) {
      case _CourierStep.headingToStore:
        return _CourierStep.atStore;
      case _CourierStep.atStore:
        return _CourierStep.pickedUp;
      case _CourierStep.pickedUp:
        return _CourierStep.headingToClient;
      case _CourierStep.headingToClient:
        return _CourierStep.atDestination;
      case _CourierStep.atDestination:
        return _CourierStep.delivered;
      case _CourierStep.delivered:
        return null;
    }
  }

  /// Determina qual ação backend precisa ser chamada ao avançar o step.
  Future<void> _handleStepAction() async {
    dev.log('[ActiveDeliveryPage] _handleStepAction — step=$_currentStep', name: 'Courier');
    switch (_currentStep) {
      // Ao confirmar retirada → chama markPickedUp no backend
      case _CourierStep.atStore:
        dev.log('[ActiveDeliveryPage] _handleStepAction — chamando markPickedUp', name: 'Courier');
        final ok = await _viewModel.markPickedUp();
        dev.log('[ActiveDeliveryPage] _handleStepAction — markPickedUp retornou: $ok', name: 'Courier');
        if (!mounted) return;
        if (ok) {
          _advanceStep();
        } else {
          _showError(_viewModel.errorMessage.value);
        }
        break;
      // Ao confirmar entrega → chama completeDelivery no backend
      case _CourierStep.atDestination:
        dev.log('[ActiveDeliveryPage] _handleStepAction — chamando completeDelivery', name: 'Courier');
        final ok = await _viewModel.completeDelivery();
        dev.log('[ActiveDeliveryPage] _handleStepAction — completeDelivery retornou: $ok', name: 'Courier');
        if (!mounted) return;
        if (ok) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.go('/courier');
          });
        } else {
          _showError(_viewModel.errorMessage.value);
        }
        break;
      // Demais steps: apenas avança localmente
      default:
        dev.log('[ActiveDeliveryPage] _handleStepAction — avanço local (sem chamada de rede)', name: 'Courier');
        _advanceStep();
        break;
    }
  }

  void _showError(String? msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Erro ao atualizar status'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Watch((context) {
          final delivery = _viewModel.activeDelivery.value;
          return Text(
              'Entrega #${delivery?.orderId ?? widget.deliveryId}');
        }),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/courier'),
        ),
      ),
      body: Watch((context) {
        final isLoading = _viewModel.isLoading.value;
        final delivery = _viewModel.activeDelivery.value;
        final isTracking = _viewModel.isTracking.value;

        if (delivery == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isCompleted = _currentStep == _CourierStep.delivered;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status de rastreamento GPS
              _TrackingBadge(isTracking: isTracking),
              const SizedBox(height: 16),

              // Informações do pedido
              if (_order != null) _OrderInfoCard(order: _order!),
              const SizedBox(height: 16),

              // Timeline de progresso
              _StepTimeline(currentStep: _currentStep),
              const SizedBox(height: 24),

              // Botão de ação
              if (!isCompleted)
                _ActionButton(
                  currentStep: _currentStep,
                  isLoading: isLoading,
                  onPressed: _handleStepAction,
                )
              else
                _CompletedBanner(
                  onGoBack: () => context.go('/courier'),
                ),

              const SizedBox(height: 16),

              // Link para o chat
              if (_order != null)
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/chat/${delivery.orderId}'),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Chat com suporte'),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ---- Widgets auxiliares ----

class _TrackingBadge extends StatelessWidget {
  final bool isTracking;

  const _TrackingBadge({required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isTracking ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isTracking
              ? 'GPS ativo — enviando localização'
              : 'GPS inativo',
          style: TextStyle(
            color: isTracking ? Colors.green[700] : Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final OrderModel order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final address = [
      order.deliveryStreet,
      order.deliveryNumber,
      if (order.deliveryComplement?.isNotEmpty == true)
        order.deliveryComplement,
      order.deliveryNeighborhood,
      order.deliveryCity,
      order.deliveryState,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pedido #${order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'R\$ ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            const Text('Endereço de entrega',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(address,
                      style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Cliente',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 2),
            Text(order.customerName,
                style: const TextStyle(fontSize: 14)),
            Text(order.customerPhone,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Itens',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            ...order.items.map((item) => Text(
                  '${item.quantity}x ${item.productName}',
                  style: const TextStyle(fontSize: 13),
                )),
          ],
        ),
      ),
    );
  }
}

class _StepTimeline extends StatelessWidget {
  final _CourierStep currentStep;

  const _StepTimeline({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = _CourierStep.values;
    final currentIndex = steps.indexOf(currentStep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progresso da entrega',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isDone = index < currentIndex;
          final isCurrent = index == currentIndex;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          : isCurrent
                              ? Colors.indigo
                              : Colors.grey[300],
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check
                          : isCurrent
                              ? Icons.radio_button_checked
                              : Icons.circle,
                      color: isDone || isCurrent
                          ? Colors.white
                          : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: isDone ? Colors.green : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 28),
                child: Text(
                  _stepLabels[step] ?? step.name,
                  style: TextStyle(
                    fontWeight: isCurrent
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCurrent
                        ? Colors.indigo
                        : isDone
                            ? Colors.green
                            : Colors.grey[500],
                    fontSize: isCurrent ? 15 : 13,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _CourierStep currentStep;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.currentStep,
    required this.isLoading,
    required this.onPressed,
  });

  String get _label {
    switch (currentStep) {
      case _CourierStep.headingToStore:
        return 'Cheguei ao estabelecimento';
      case _CourierStep.atStore:
        return 'Confirmei a retirada do pedido';
      case _CourierStep.pickedUp:
        return 'Saí para entrega';
      case _CourierStep.headingToClient:
        return 'Cheguei ao destino';
      case _CourierStep.atDestination:
        return 'Confirmar entrega ao cliente';
      default:
        return '';
    }
  }

  Color get _color {
    if (currentStep == _CourierStep.atDestination) return Colors.green;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(_label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final VoidCallback onGoBack;

  const _CompletedBanner({required this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Entrega concluída!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ótimo trabalho! O cliente recebeu o pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onGoBack,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
