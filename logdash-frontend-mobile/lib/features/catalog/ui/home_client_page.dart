import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/cart/cart_signal.dart';
import 'package:logdash_frontend_mobile/features/catalog/catalog_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeClientPage extends StatefulWidget {
  const HomeClientPage({super.key});

  @override
  State<HomeClientPage> createState() => _HomeClientPageState();
}

class _HomeClientPageState extends State<HomeClientPage> {
  final _viewModel = injector.get<CatalogViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel.loadCategories();
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _viewModel.loadProducts(
        categoryId: _viewModel.selectedCategoryId.value,
        name: query.isEmpty ? null : query,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Watch((context) {
          final user = _authViewModel.currentUser.value;
          return Text('Olá, ${user?.displayName.split(' ').first ?? ''}!');
        }),
        actions: [
          Watch((context) {
            final count = cartCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.push('/cart'),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authViewModel.logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Watch((context) {
        final categories = _viewModel.categories.value;
        final products = _viewModel.products.value;
        final isLoading = _viewModel.isLoading.value;
        final selectedId = _viewModel.selectedCategoryId.value;

        return Column(
          children: [
            if (categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: const Text('Todos'),
                        selected: selectedId == null,
                        onSelected: (_) => _viewModel.selectCategory(null),
                      );
                    }
                    final cat = categories[index - 1];
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: selectedId == cat.id,
                      onSelected: (_) => _viewModel.selectCategory(cat.id),
                    );
                  },
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const Center(
                          child: Text('Nenhum produto encontrado'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: product.imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: product.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorWidget: (_, _, _) =>
                                                const Icon(Icons.fastfood,
                                                    size: 48,
                                                    color: Colors.grey),
                                          )
                                        : Container(
                                            color: Colors.grey[100],
                                            child: const Center(
                                              child: Icon(Icons.fastfood,
                                                  size: 48,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'R\$ ${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: product.available
                                                ? () => addToCart(product)
                                                : null,
                                            icon: const Icon(Icons.add,
                                                size: 16),
                                            label: const Text('Adicionar',
                                                style:
                                                    TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Meus Pedidos'),
        ],
        onTap: (index) {
          if (index == 1) context.push('/my-orders');
        },
      ),
    );
  }
}
