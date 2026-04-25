/// Payload enviado via STOMP para /app/delivery/{id}/location.
/// Corresponde ao LocationUpdateMessage do backend.
class LocationUpdateModel {
  final String courierId;
  final int deliveryId;
  final int orderId;
  final String timestamp;
  final double latitude;
  final double longitude;
  final String status;

  const LocationUpdateModel({
    required this.courierId,
    required this.deliveryId,
    required this.orderId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'courierId': courierId,
        'deliveryId': deliveryId,
        'orderId': orderId,
        'timestamp': timestamp,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
      };
}
