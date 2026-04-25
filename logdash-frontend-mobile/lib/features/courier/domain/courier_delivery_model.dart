/// Representa uma entrega ativa do entregador, com o status da entrega (DeliveryStatus)
/// e as informações do pedido associado.
class CourierDeliveryModel {
  final int id;
  final int orderId;
  final int? courierId;
  final String? courierName;
  final String status; // PENDING | ASSIGNED | PICKED_UP | DELIVERED
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const CourierDeliveryModel({
    required this.id,
    required this.orderId,
    this.courierId,
    this.courierName,
    required this.status,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.createdAt,
  });

  factory CourierDeliveryModel.fromJson(Map<String, dynamic> json) {
    return CourierDeliveryModel(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      courierId: json['courierId'] as int?,
      courierName: json['courierName'] as String?,
      status: json['status'] as String,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isCompleted => status == 'DELIVERED';
  bool get isAssigned => status == 'ASSIGNED';
  bool get isPickedUp => status == 'PICKED_UP';
}
