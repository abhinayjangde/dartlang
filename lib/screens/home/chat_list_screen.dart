import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat_list_tile.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/group_create_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
      context.read<ChatProvider>().updateOnlineStatus(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupCreateScreen())),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();
                await chatProvider.updateOnlineStatus(false);
                authProvider.logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Row(
                children: [Icon(Icons.logout, size: 20), SizedBox(width: 8), Text('Logout')],
              )),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Text('Tap + to start a new chat', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => chatProvider.loadChats(),
            child: ListView.separated(
              itemCount: chatProvider.chats.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                return ChatListTile(
                  chat: chat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(chatId: chat.id, chatName: chat.displayName),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showNewChatSheet(context),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  void _showNewChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NewChatSheet(),
    );
  }
}

class _NewChatSheet extends StatefulWidget {
  @override
  State<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<_NewChatSheet> {
  List<dynamic>? _users;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await context.read<AuthProvider>().authService.getUsers();
      setState(() => _users = users);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('New Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_users == null)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _users!.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _users![index] as dynamic;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((user.displayName as String)[0].toUpperCase()),
                        ),
                        title: Text(user.displayName as String),
                        subtitle: Text(user.isOnline == true ? 'Online' : 'Offline'),
                        onTap: () async {
                          final chatProvider = context.read<ChatProvider>();
                          final chatName = user.displayName as String;
                          Navigator.pop(context);
                          final chatId = await chatProvider.getOrCreateChat(user.id);
                          if (chatId != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(chatId: chatId, chatName: chatName),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
