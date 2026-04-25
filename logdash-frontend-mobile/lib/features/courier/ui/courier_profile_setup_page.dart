import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/courier/courier_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Tela exibida na primeira vez que um entregador (role COURIER) acessa o app
/// e ainda não tem perfil cadastrado no sistema.
/// Chama POST /api/couriers/me e redireciona para CourierHomePage.
class CourierProfileSetupPage extends StatefulWidget {
  const CourierProfileSetupPage({super.key});

  @override
  State<CourierProfileSetupPage> createState() =>
      _CourierProfileSetupPageState();
}

class _CourierProfileSetupPageState extends State<CourierProfileSetupPage> {
  final _viewModel = injector.get<CourierViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vehicleTypeCtrl = TextEditingController();
  final _vehiclePlateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche nome com o display name do usuário logado como sugestão
    final user = _authViewModel.currentUser.value;
    if (user != null) _nameCtrl.text = user.displayName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _viewModel.registerProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      vehicleType: _vehicleTypeCtrl.text.trim(),
      vehiclePlate: _vehiclePlateCtrl.text.trim().toUpperCase(),
    );
    if (!mounted) return;
    if (ok) {
      context.go('/courier');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_viewModel.errorMessage.value ?? 'Erro ao cadastrar perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure seu perfil'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label:
                const Text('Sair', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await _authViewModel.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Watch((context) {
        final isLoading = _viewModel.isLoading.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                const Icon(Icons.delivery_dining,
                    size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'Bem-vindo ao LogDash!',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Para começar a receber entregas, preencha seu perfil de entregador.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Nome
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),

                // Telefone
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Telefone / WhatsApp *',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '(11) 99999-9999',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Informe seu telefone'
                      : null,
                ),
                const SizedBox(height: 16),

                // Tipo de veículo
                TextFormField(
                  controller: _vehicleTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de veículo',
                    prefixIcon: Icon(Icons.two_wheeler_outlined),
                    hintText: 'Moto, Bicicleta, Carro...',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Placa
                TextFormField(
                  controller: _vehiclePlateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa do veículo',
                    prefixIcon: Icon(Icons.pin_outlined),
                    hintText: 'ABC-1234 ou ABC1D23',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 32),

                // Botão
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
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
                        : const Text('Salvar e começar',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
