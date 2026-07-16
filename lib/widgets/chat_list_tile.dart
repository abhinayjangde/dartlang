import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';
import 'avatar_widget.dart';

class ChatListTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMsg = chat.lastMessage;
    final timeStr = lastMsg != null
        ? DateFormat('HH:mm').format(lastMsg.createdAt)
        : '';

    String subtitle;
    if (lastMsg == null) {
      subtitle = 'No messages yet';
    } else if (lastMsg.isImage) {
      subtitle = '📷 Photo';
    } else if (lastMsg.isFile) {
      subtitle = '📎 File';
    } else if (lastMsg.isSystem) {
      subtitle = lastMsg.content ?? '';
    } else {
      subtitle = lastMsg.content ?? '';
    }
    if (chat.isGroup && lastMsg?.sender != null) {
      subtitle = '${lastMsg!.sender!.displayName}: $subtitle';
    }

    return ListTile(
      leading: AvatarWidget(
        imageUrl: chat.avatarUrl,
        name: chat.displayName,
        radius: 28,
      ),
      title: Text(
        chat.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Text(
        timeStr,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
