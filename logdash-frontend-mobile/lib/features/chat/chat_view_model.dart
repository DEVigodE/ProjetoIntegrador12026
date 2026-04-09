import 'package:logdash_frontend_mobile/features/chat/data/chat_repository.dart';
import 'package:logdash_frontend_mobile/features/chat/domain/message_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatViewModel {
  final ChatRepository _repository;

  ChatViewModel(this._repository);

  final Signal<List<MessageModel>> messages = signal([]);
  final Signal<bool> isLoading = signal(false);
  final Signal<bool> isSending = signal(false);
  final Signal<String?> errorMessage = signal(null);

  Future<void> loadMessages(int orderId) async {
    isLoading.set(true);
    final result = await _repository.getMessages(orderId);
    isLoading.set(false);
    result.fold(
      (list) => messages.set(list),
      (err) => errorMessage.set(_parseError(err)),
    );
  }

  Future<bool> sendMessage(
      int orderId, String content, String senderId) async {
    if (content.trim().isEmpty) return false;
    isSending.set(true);
    final result =
        await _repository.sendMessage(orderId, content.trim(), senderId);
    isSending.set(false);
    bool sent = false;
    result.fold(
      (msg) {
        messages.set([...messages.value, msg]);
        sent = true;
      },
      (err) => errorMessage.set(_parseError(err)),
    );
    return sent;
  }

  String _parseError(Exception err) =>
      err.toString().replaceFirst('Exception: ', '');
}
