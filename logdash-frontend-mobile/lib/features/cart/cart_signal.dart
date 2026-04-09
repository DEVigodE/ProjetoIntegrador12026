import 'package:logdash_frontend_mobile/features/cart/domain/cart_item_model.dart';
import 'package:logdash_frontend_mobile/features/catalog/domain/product_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

final cartItems = signal<List<CartItemModel>>([]);

int get cartCount =>
    cartItems.value.fold(0, (sum, item) => sum + item.quantity);

double get cartTotal =>
    cartItems.value.fold(0.0, (sum, item) => sum + item.subtotal);

void addToCart(ProductModel product) {
  final currentItems = List<CartItemModel>.from(cartItems.value);
  final index = currentItems.indexWhere((i) => i.product.id == product.id);
  if (index >= 0) {
    currentItems[index].quantity++;
  } else {
    currentItems.add(CartItemModel(product: product));
  }
  cartItems.set(currentItems);
}

void incrementCart(int productId) {
  final currentItems = List<CartItemModel>.from(cartItems.value);
  final index = currentItems.indexWhere((i) => i.product.id == productId);
  if (index >= 0) {
    currentItems[index].quantity++;
    cartItems.set(currentItems);
  }
}

void decrementCart(int productId) {
  final currentItems = List<CartItemModel>.from(cartItems.value);
  final index = currentItems.indexWhere((i) => i.product.id == productId);
  if (index >= 0) {
    if (currentItems[index].quantity > 1) {
      currentItems[index].quantity--;
    } else {
      currentItems.removeAt(index);
    }
    cartItems.set(currentItems);
  }
}

void removeFromCart(int productId) {
  cartItems.set(
    cartItems.value.where((i) => i.product.id != productId).toList(),
  );
}

void clearCart() {
  cartItems.set([]);
}
