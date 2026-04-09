import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/cart/cart_signal.dart';
import 'package:logdash_frontend_mobile/features/orders/domain/order_request_model.dart';
import 'package:logdash_frontend_mobile/features/orders/orders_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _ordersViewModel = injector.get<OrdersViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();

  late final TextEditingController _phoneCtrl;
  final _cepCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _lookingUpCep = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cepCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupCep(String cep) async {
    final cleaned = cep.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 8) return;
    setState(() => _lookingUpCep = true);
    try {
      final dio = Dio();
      final response =
          await dio.get('https://viacep.com.br/ws/$cleaned/json/');
      final data = response.data as Map<String, dynamic>;
      if (data['erro'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
        return;
      }
      _streetCtrl.text = data['logradouro'] as String? ?? '';
      _neighborhoodCtrl.text = data['bairro'] as String? ?? '';
      _cityCtrl.text = data['localidade'] as String? ?? '';
      _stateCtrl.text = data['uf'] as String? ?? '';
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao consultar CEP')),
        );
      }
    } finally {
      setState(() => _lookingUpCep = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (cartItems.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seu carrinho está vazio')),
      );
      return;
    }

    final user = _authViewModel.currentUser.value!;
    final request = OrderRequestModel(
      customerName: user.displayName,
      customerPhone: _phoneCtrl.text.trim(),
      customerEmail: user.email,
      deliveryStreet: _streetCtrl.text.trim(),
      deliveryNumber: _numberCtrl.text.trim(),
      deliveryComplement: _complementCtrl.text.trim().isEmpty
          ? null
          : _complementCtrl.text.trim(),
      deliveryNeighborhood: _neighborhoodCtrl.text.trim(),
      deliveryCity: _cityCtrl.text.trim(),
      deliveryState: _stateCtrl.text.trim(),
      deliveryZipCode: _cepCtrl.text.trim(),
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      cartItems: cartItems.value,
    );

    final order = await _ordersViewModel.placeOrder(request);
    if (!mounted) return;

    if (order != null) {
      clearCart();
      context.go('/order/${order.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _ordersViewModel.errorMessage.value ?? 'Erro ao criar pedido'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Dados de contato'),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),
              _section('Endereço de entrega'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepCtrl,
                      decoration: InputDecoration(
                        labelText: 'CEP *',
                        prefixIcon: _lookingUpCep
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        if (v.replaceAll(RegExp(r'\D'), '').length == 8) {
                          _lookupCep(v);
                        }
                      },
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Informe o CEP' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetCtrl,
                decoration:
                    const InputDecoration(labelText: 'Rua *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numberCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Número *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Informe o número'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _complementCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Complemento'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _neighborhoodCtrl,
                decoration:
                    const InputDecoration(labelText: 'Bairro *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o bairro' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Cidade *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Informe a cidade'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration:
                          const InputDecoration(labelText: 'UF *'),
                      maxLength: 2,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'UF' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _section('Observações'),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Observações do pedido',
                    hintText: 'Ex: sem cebola, troco para R\$50...'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _section('Resumo do pedido'),
              Watch((context) {
                final items = cartItems.value;
                return Column(
                  children: [
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    '${item.quantity}x ${item.product.name}')),
                            Text(
                                'R\$ ${item.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'R\$ ${cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Watch((context) {
                final loading = _ordersViewModel.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirmar Pedido',
                            style: TextStyle(fontSize: 16)),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
