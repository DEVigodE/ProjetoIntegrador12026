import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
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
  Timer? _pollingTimer;

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
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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

        final isCancelled = order.status == 'CANCELLED';
        final currentStepIndex = isCancelled
            ? -1
            : _statusSteps.indexOf(order.status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          color: _statusColors[order.status] ?? Colors.grey,
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
                              color: isDone ? Colors.white : Colors.grey[400],
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
                            color: isCurrent ? Colors.green : Colors.grey[600],
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
                          child: Text('${item.quantity}x ${item.productName}')),
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
}
