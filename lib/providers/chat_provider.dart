import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/graphql_service.dart';
import '../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final GraphqlService _graphqlService;
  final AuthService _authService;
  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _messageSubscription;


  ChatProvider(this._graphqlService, this._authService);

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _graphqlService.client.query(
        QueryOptions(
          document: gql(GraphqlService.getChatsQuery),
          variables: {'user_id': _authService.currentUser!.id},
        ),
      );
      if (result.hasException) {
        _error = result.exception.toString();
      } else {
        final data = result.data?['chats'] as List<dynamic>? ?? [];
        _chats = data.map((e) => Chat.fromJson(e as Map<String, dynamic>)).toList();
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _graphqlService.client.query(
        QueryOptions(
          document: gql(GraphqlService.getMessagesQuery),
          variables: {'chat_id': chatId},
        ),
      );
      if (result.hasException) {
        _error = result.exception.toString();
      } else {
        final data = result.data?['messages'] as List<dynamic>? ?? [];
        _messages = data.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void subscribeToMessages(String chatId) {
    _messageSubscription?.cancel();
    final streamResult = _graphqlService.client.subscribe(
      SubscriptionOptions(
        document: gql(GraphqlService.messagesSubscription),
        variables: {'chat_id': chatId},
      ),
    );
    _messageSubscription = streamResult.listen(
      (result) {
        if (result.hasException) {
          _error = result.exception.toString();
          notifyListeners();
          return;
        }
        final data = result.data?['messages'] as List<dynamic>? ?? [];
        _messages = data.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void unsubscribeFromMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  Future<void> sendMessage({
    required String chatId,
    String? content,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    try {
      await _graphqlService.client.mutate(
        MutationOptions(
          document: gql(GraphqlService.sendMessageMutation),
          variables: {
            'chat_id': chatId,
            'sender_id': _authService.currentUser!.id,
            'content': content,
            'message_type': messageType,
            'media_url': mediaUrl,
          },
        ),
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> getOrCreateChat(String otherUserId) async {
    try {
      final result = await _graphqlService.client.mutate(
        MutationOptions(
          document: gql(GraphqlService.getOrCreateChatMutation),
          variables: {
            'user_id': _authService.currentUser!.id,
            'other_user_id': otherUserId,
          },
        ),
      );
      if (result.hasException) {
        _error = result.exception.toString();
        return null;
      }
      final chat = result.data?['insert_chats_one'] as Map<String, dynamic>?;
      return chat?['id'] as String?;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _graphqlService.client.mutate(
        MutationOptions(
          document: gql(GraphqlService.updateOnlineStatusMutation),
          variables: {
            'user_id': _authService.currentUser!.id,
            'is_online': isOnline,
          },
        ),
      );
    } catch (_) {}
  }

  Future<void> createGroupChat(String name, List<String> userIds) async {
    try {
      final participants = userIds.map((id) => {'user_id': id}).toList();
      await _graphqlService.client.mutate(
        MutationOptions(
          document: gql(GraphqlService.createGroupChatMutation),
          variables: {
            'name': name,
            'created_by': _authService.currentUser!.id,
            'participants': participants,
          },
        ),
      );
      await loadChats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      await _graphqlService.client.mutate(
        MutationOptions(
          document: gql(GraphqlService.updateMessageStatusMutation),
          variables: {
            'message_id': messageId,
            'user_id': _authService.currentUser!.id,
            'status': status,
          },
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
