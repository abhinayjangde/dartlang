import 'user.dart';
import 'message.dart';

class Chat {
  final String id;
  final String? name;
  final bool isGroup;
  final String? createdBy;
  final DateTime? createdAt;
  final List<AppUser>? participants;
  final Message? lastMessage;

  Chat({
    required this.id,
    this.name,
    required this.isGroup,
    this.createdBy,
    this.createdAt,
    this.participants,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => AppUser.fromJson(e['user'] as Map<String, dynamic>))
          .toList(),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  String get displayName {
    if (isGroup && name != null) return name!;
    if (participants != null && participants!.isNotEmpty) {
      return participants!.first.displayName;
    }
    return 'Unknown';
  }

  String? get avatarUrl {
    if (!isGroup && participants != null && participants!.isNotEmpty) {
      return participants!.first.avatarUrl;
    }
    return null;
  }
}
