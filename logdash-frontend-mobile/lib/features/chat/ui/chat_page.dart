import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/auth_view_model.dart';
import 'package:logdash_frontend_mobile/features/chat/chat_view_model.dart';
import 'package:logdash_frontend_mobile/features/chat/domain/message_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatPage extends StatefulWidget {
  final int orderId;

  const ChatPage({super.key, required this.orderId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _viewModel = injector.get<ChatViewModel>();
  final _authViewModel = injector.get<AuthViewModel>();
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _viewModel.loadMessages(widget.orderId);
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _viewModel.loadMessages(widget.orderId);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final content = _messageCtrl.text;
    final user = _authViewModel.currentUser.value;
    if (user == null || content.trim().isEmpty) return;

    _messageCtrl.clear();
    final sent = await _viewModel.sendMessage(
        widget.orderId, content, user.id);
    if (sent) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat — Pedido #${widget.orderId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Watch((context) {
              final messages = _viewModel.messages.value;
              final isLoading = _viewModel.isLoading.value;

              if (isLoading && messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (messages.isEmpty) {
                return const Center(
                  child: Text('Nenhuma mensagem ainda.',
                      style: TextStyle(color: Colors.grey)),
                );
              }

              _scrollToBottom();
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (_, index) =>
                    _MessageBubble(message: messages[index]),
              );
            }),
          ),
          _InputBar(
            controller: _messageCtrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isCustomer;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[400] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderType == 'SYSTEM' ? 'Sistema' : 'Suporte',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            Text(
              message.content,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.sentAt),
              style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
