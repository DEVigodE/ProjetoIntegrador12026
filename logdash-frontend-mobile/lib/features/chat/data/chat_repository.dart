import 'package:logdash_frontend_mobile/features/chat/data/chat_service.dart';
import 'package:logdash_frontend_mobile/features/chat/domain/message_model.dart';
import 'package:result_dart/result_dart.dart';

class ChatRepository {
  final ChatService _service;

  ChatRepository(this._service);

  AsyncResult<List<MessageModel>> getMessages(int orderId) =>
      _service.getMessages(orderId);

  AsyncResult<MessageModel> sendMessage(
          int orderId, String content, String senderId) =>
      _service.sendMessage(orderId, content, senderId);
}
