import 'user.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String messageType;
  final String? mediaUrl;
  final String? mediaThumbnailUrl;
  final String? replyToId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final AppUser? sender;
  final String? status;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.mediaThumbnailUrl,
    this.replyToId,
    required this.createdAt,
    this.updatedAt,
    this.sender,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      mediaThumbnailUrl: json['media_thumbnail_url'] as String?,
      replyToId: json['reply_to_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      sender: json['sender'] != null
          ? AppUser.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
    );
  }

  bool get isMedia => messageType == 'image' || messageType == 'file';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';
  bool get isSystem => messageType == 'system';
}
