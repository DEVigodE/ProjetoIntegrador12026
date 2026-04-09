import 'package:dio/dio.dart';
import 'package:logdash_frontend_mobile/features/chat/domain/message_model.dart';
import 'package:result_dart/result_dart.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  AsyncResult<List<MessageModel>> getMessages(int orderId) async {
    try {
      final response =
          await _dio.get('/api/chat/$orderId/messages');
      final list = (response.data as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao carregar mensagens';
      return Failure(Exception(msg.toString()));
    }
  }

  AsyncResult<MessageModel> sendMessage(
      int orderId, String content, String senderId) async {
    try {
      final response = await _dio.post(
        '/api/chat/$orderId/messages',
        data: {
          'senderId': senderId,
          'senderType': 'CUSTOMER',
          'content': content,
        },
      );
      return Success(
          MessageModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Erro ao enviar mensagem';
      return Failure(Exception(msg.toString()));
    }
  }
}
