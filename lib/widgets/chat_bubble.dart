import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && message.sender != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: message.sender!.avatarUrl != null
                    ? NetworkImage(message.sender!.avatarUrl!)
                    : null,
                child: message.sender!.avatarUrl == null
                    ? Text(
                        message.sender!.displayName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      )
                    : null,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.teal[500] : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isImage && message.mediaUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.mediaUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  if (message.content != null && message.content!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: message.isImage ? 6 : 0),
                      child: Text(
                        message.content!,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _statusIcon(),
            ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    if (message.status == null) return const SizedBox(width: 16);
    IconData icon;
    Color color;
    switch (message.status!) {
      case 'read':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      default:
        icon = Icons.done;
        color = Colors.grey;
    }
    return Icon(icon, size: 16, color: color);
  }
}
