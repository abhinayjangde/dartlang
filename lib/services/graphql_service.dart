import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/ast.dart' show OperationType;
import '../config/constants.dart';
import 'auth_service.dart';

class GraphqlService {
  GraphQLClient? _client;
  final AuthService _authService;

  GraphqlService(this._authService);

  GraphQLClient get client {
    if (_client == null) _initClient();
    return _client!;
  }

  void _initClient() {
    final httpLink = HttpLink(Constants.graphqlEndpoint);
    final authLink = AuthLink(
      getToken: () async => _authService.token != null
          ? 'Bearer ${_authService.token}'
          : 'admin ${Constants.hasuraAdminSecret}',
    );
    final httpLinkWithAuth = authLink.concat(httpLink);

    final wsLink = WebSocketLink(
      Constants.graphqlEndpoint.replaceFirst('http', 'ws'),
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: const Duration(seconds: 30),
        initialPayload: () => {
          'headers': {
            if (_authService.token != null)
              'Authorization': 'Bearer ${_authService.token}'
            else
              'X-Hasura-Admin-Secret': Constants.hasuraAdminSecret,
          },
        },
      ),
    );

    final link = Link.split(
      (request) => request.operation.getOperationType() == OperationType.subscription,
      wsLink,
      httpLinkWithAuth,
    );

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        watchQuery: Policies(fetch: FetchPolicy.networkOnly),
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );
  }

  void resetClient() {
    _client = null;
  }

  static const String getOrCreateChatMutation = '''
    mutation GetOrCreateChat(\$user_id: uuid!, \$other_user_id: uuid!) {
      insert_chats_one(
        object: {
          is_group: false,
          participants: {
            data: [
              { user_id: \$user_id },
              { user_id: \$other_user_id }
            ]
          }
        }
        on_conflict: {
          constraint: chat_participants_chat_id_user_id_key,
          update_columns: []
        }
      ) {
        id
        name
        is_group
        created_at
      }
    }
  ''';

  static const String sendMessageMutation = '''
    mutation SendMessage(\$chat_id: uuid!, \$sender_id: uuid!, \$content: String, \$message_type: String!, \$media_url: String) {
      insert_messages_one(object: {
        chat_id: \$chat_id,
        sender_id: \$sender_id,
        content: \$content,
        message_type: \$message_type,
        media_url: \$media_url
      }) {
        id
        chat_id
        sender_id
        content
        message_type
        media_url
        created_at
      }
    }
  ''';

  static const String getChatsQuery = '''
    query GetChats(\$user_id: uuid!) {
      chats(
        where: { participants: { user_id: { _eq: \$user_id } } }
        order_by: { created_at: desc }
      ) {
        id
        name
        is_group
        created_by
        created_at
        participants {
          user {
            id
            username
            display_name
            avatar_url
            is_online
            last_seen
          }
        }
        last_message: messages(order_by: { created_at: desc }, limit: 1) {
          id
          chat_id
          sender_id
          content
          message_type
          media_url
          created_at
          sender {
            id
            display_name
          }
        }
      }
    }
  ''';

  static const String getMessagesQuery = '''
    query GetMessages(\$chat_id: uuid!) {
      messages(
        where: { chat_id: { _eq: \$chat_id } }
        order_by: { created_at: asc }
      ) {
        id
        chat_id
        sender_id
        content
        message_type
        media_url
        media_thumbnail_url
        reply_to_id
        created_at
        updated_at
        sender {
          id
          username
          display_name
          avatar_url
        }
      }
    }
  ''';

  static const String messagesSubscription = '''
    subscription OnNewMessage(\$chat_id: uuid!) {
      messages(
        where: { chat_id: { _eq: \$chat_id } }
        order_by: { created_at: asc }
      ) {
        id
        chat_id
        sender_id
        content
        message_type
        media_url
        media_thumbnail_url
        reply_to_id
        created_at
        updated_at
        sender {
          id
          username
          display_name
          avatar_url
        }
      }
    }
  ''';

  static const String updateOnlineStatusMutation = '''
    mutation UpdateOnlineStatus(\$user_id: uuid!, \$is_online: Boolean!) {
      update_users_by_pk(
        pk_columns: { id: \$user_id }
        _set: { is_online: \$is_online, last_seen: now() }
      ) {
        id
        is_online
        last_seen
      }
    }
  ''';

  static const String createGroupChatMutation = '''
    mutation CreateGroupChat(\$name: String!, \$created_by: uuid!, \$participants: [chat_participants_insert_input!]!) {
      insert_chats_one(
        object: {
          name: \$name,
          is_group: true,
          created_by: \$created_by,
          participants: {
            data: \$participants
          }
        }
      ) {
        id
        name
        is_group
        created_at
      }
    }
  ''';

  static const String updateMessageStatusMutation = '''
    mutation UpdateMessageStatus(\$message_id: uuid!, \$user_id: uuid!, \$status: String!) {
      insert_message_status_one(
        object: {
          message_id: \$message_id,
          user_id: \$user_id,
          status: \$status
        }
        on_conflict: {
          constraint: message_status_message_id_user_id_key,
          update_columns: [status, updated_at]
        }
      ) {
        id
        status
        updated_at
      }
    }
  ''';
}
