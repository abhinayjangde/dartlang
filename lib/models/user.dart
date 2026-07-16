class AppUser {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? phone;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.phone,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'phone': phone,
    'is_online': isOnline,
    'last_seen': lastSeen?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? phone,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
