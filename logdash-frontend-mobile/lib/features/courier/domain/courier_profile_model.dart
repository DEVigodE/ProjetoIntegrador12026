/// Representa o perfil do entregador retornado por GET/POST /api/couriers/me.
/// Corresponde ao CourierResponse do backend.
class CourierProfileModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? vehicleType;
  final String? vehiclePlate;
  final String status; // AVAILABLE | BUSY | OFFLINE
  final bool active;

  const CourierProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.vehicleType,
    this.vehiclePlate,
    required this.status,
    required this.active,
  });

  factory CourierProfileModel.fromJson(Map<String, dynamic> json) {
    return CourierProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      status: json['status'] as String? ?? 'OFFLINE',
      active: json['active'] as bool? ?? true,
    );
  }

  bool get isAvailable => status == 'AVAILABLE' && active;
}
