class MessageModel {
  final int id;
  final String senderId;
  final String senderType;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.sentAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as String,
      senderType: json['senderType'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  bool get isCustomer => senderType == 'CUSTOMER';
}
