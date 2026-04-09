import 'package:logdash_frontend_mobile/features/orders/domain/order_item_model.dart';

class OrderModel {
  final int id;
  final String status;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerId;
  final String? deliveryStreet;
  final String? deliveryNumber;
  final String? deliveryComplement;
  final String? deliveryNeighborhood;
  final String? deliveryCity;
  final String? deliveryState;
  final String? deliveryZipCode;
  final double totalAmount;
  final String? notes;
  final String? rejectedReason;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.customerId,
    this.deliveryStreet,
    this.deliveryNumber,
    this.deliveryComplement,
    this.deliveryNeighborhood,
    this.deliveryCity,
    this.deliveryState,
    this.deliveryZipCode,
    required this.totalAmount,
    this.notes,
    this.rejectedReason,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      status: json['status'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerEmail: json['customerEmail'] as String?,
      customerId: json['customerId'] as String?,
      deliveryStreet: json['deliveryStreet'] as String?,
      deliveryNumber: json['deliveryNumber'] as String?,
      deliveryComplement: json['deliveryComplement'] as String?,
      deliveryNeighborhood: json['deliveryNeighborhood'] as String?,
      deliveryCity: json['deliveryCity'] as String?,
      deliveryState: json['deliveryState'] as String?,
      deliveryZipCode: json['deliveryZipCode'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      rejectedReason: json['rejectedReason'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isTerminal => status == 'DELIVERED' || status == 'CANCELLED';
}
