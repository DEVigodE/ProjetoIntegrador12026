import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_model.dart';
import 'package:logdash_frontend_mobile/features/orders/orders_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

const _statusLabels = {
  'PENDING': 'Aguardando',
  'ACCEPTED': 'Aceito',
  'PREPARING': 'Em preparo',
  'READY': 'Pronto',
  'OUT_FOR_DELIVERY': 'A caminho',
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

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final _viewModel = injector.get<OrdersViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.loadMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: Watch((context) {
        final orders = _viewModel.myOrders.value;
        final isLoading = _viewModel.isLoading.value;

        if (isLoading && orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum pedido encontrado',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _viewModel.loadMyOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _OrderCard(order: orders[index]),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[order.status] ?? Colors.grey;
    final label = _statusLabels[order.status] ?? order.status;

    return Card(
      child: InkWell(
        onTap: () => context.push('/order/${order.id}'),
        borderRadius: BorderRadius.circular(12),
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
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
