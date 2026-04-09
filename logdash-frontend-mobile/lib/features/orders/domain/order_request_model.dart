import 'package:logdash_frontend_mobile/features/cart/domain/cart_item_model.dart';

class OrderRequestModel {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String deliveryStreet;
  final String deliveryNumber;
  final String? deliveryComplement;
  final String deliveryNeighborhood;
  final String deliveryCity;
  final String deliveryState;
  final String deliveryZipCode;
  final String? notes;
  final List<CartItemModel> cartItems;

  const OrderRequestModel({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.deliveryStreet,
    required this.deliveryNumber,
    this.deliveryComplement,
    required this.deliveryNeighborhood,
    required this.deliveryCity,
    required this.deliveryState,
    required this.deliveryZipCode,
    this.notes,
    required this.cartItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      if (customerEmail != null) 'customerEmail': customerEmail,
      'deliveryStreet': deliveryStreet,
      'deliveryNumber': deliveryNumber,
      if (deliveryComplement != null) 'deliveryComplement': deliveryComplement,
      'deliveryNeighborhood': deliveryNeighborhood,
      'deliveryCity': deliveryCity,
      'deliveryState': deliveryState,
      'deliveryZipCode': deliveryZipCode,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'items': cartItems
          .map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'unitPrice': item.product.price,
                'quantity': item.quantity,
              })
          .toList(),
    };
  }
}
