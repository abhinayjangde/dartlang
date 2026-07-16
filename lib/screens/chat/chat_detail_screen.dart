import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/message_input.dart';
import '../../services/media_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatDetailScreen({super.key, required this.chatId, required this.chatName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();
  final _mediaService = MediaService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.loadMessages(widget.chatId);
      chatProvider.subscribeToMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().unsubscribeFromMessages();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(chatId: widget.chatId, content: text);
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    final chatProvider = context.read<ChatProvider>();
    final path = await _mediaService.pickImage();
    if (path != null) {
      chatProvider.sendMessage(
        chatId: widget.chatId,
        messageType: 'image',
        mediaUrl: path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chatProvider.messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet', style: TextStyle(color: Colors.grey[500])),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isMe = message.senderId == currentUserId;
                    final showDate = index == 0 ||
                        chatProvider.messages[index - 1].createdAt.day != message.createdAt.day;
                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              DateFormat('MMM d, y').format(message.createdAt),
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ),
                        ChatBubble(message: message, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSend: _sendMessage,
            onImageTap: _pickAndSendImage,
          ),
        ],
      ),
    );
  }
}
