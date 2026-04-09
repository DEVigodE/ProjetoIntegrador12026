import 'package:logdash_frontend_mobile/features/catalog/domain/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}
