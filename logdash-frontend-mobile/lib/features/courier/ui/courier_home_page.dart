import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/courier/courier_view_model.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CourierHomePage extends StatefulWidget {
  const CourierHomePage({super.key});

  @override
  State<CourierHomePage> createState() => _CourierHomePageState();
}

class _CourierHomePageState extends State<CourierHomePage> {
  final _viewModel = injector.get<CourierViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAndCheck();
    // Recarrega a cada 15 segundos para manter lista atualizada
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _viewModel.loadInitialData(),
    );
  }

  Future<void> _loadAndCheck() async {
    await _viewModel.loadInitialData();
    if (!mounted) return;
    // Se não tem perfil, redireciona para o setup
    if (_viewModel.needsProfileSetup.value) {
      context.go('/courier/setup');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _acceptOrder(int orderId) async {
    final ok = await _viewModel.acceptOrder(orderId);
    if (!mounted) return;
    if (ok) {
      final delivery = _viewModel.activeDelivery.value;
      if (delivery != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido aceito! Dirija-se ao estabelecimento.'),
            backgroundColor: Colors.green,
          ),
        );
        context.push('/courier/delivery/${delivery.id}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage.value ?? 'Erro ao aceitar pedido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LogDash — Entregador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _viewModel.loadInitialData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              _viewModel.stopTracking();
              await _authViewModel.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Watch((context) {
        final isLoading = _viewModel.isLoading.value;
        final activeDelivery = _viewModel.activeDelivery.value;
        final availableOrders = _viewModel.availableOrders.value;
        final user = _authViewModel.currentUser.value;

        if (isLoading && activeDelivery == null && availableOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _viewModel.loadInitialData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Saudação
              Text(
                'Olá, ${user?.displayName ?? 'Entregador'}!',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Card entrega ativa
              if (activeDelivery != null) ...[
                _SectionHeader(
                  icon: Icons.local_shipping,
                  label: 'Entrega em andamento',
                  color: Colors.indigo,
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.indigo[50],
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.delivery_dining,
                          color: Colors.white),
                    ),
                    title: Text('Pedido #${activeDelivery.orderId}'),
                    subtitle: Text(
                      _deliveryStatusLabel(activeDelivery.status),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push('/courier/delivery/${activeDelivery.id}'),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Lista de pedidos disponíveis
              _SectionHeader(
                icon: Icons.list_alt,
                label: 'Pedidos disponíveis',
                color: Colors.green,
              ),
              const SizedBox(height: 8),

              if (availableOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Nenhum pedido disponível no momento.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...availableOrders.map(
                  (order) => _AvailableOrderCard(
                    order: order,
                    onAccept: activeDelivery == null
                        ? () => _acceptOrder(order.id)
                        : null,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _deliveryStatusLabel(String status) {
    const labels = {
      'PENDING': 'Aguardando início',
      'ASSIGNED': 'A caminho do estabelecimento',
      'PICKED_UP': 'A caminho do cliente',
      'DELIVERED': 'Entregue',
    };
    return labels[status] ?? status;
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAccept;

  const _AvailableOrderCard({required this.order, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final address = [
      order.deliveryStreet,
      order.deliveryNumber,
      order.deliveryNeighborhood,
      order.deliveryCity,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'R\$ ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (address.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(onAccept == null
                    ? 'Você já tem uma entrega ativa'
                    : 'Aceitar pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      onAccept == null ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
