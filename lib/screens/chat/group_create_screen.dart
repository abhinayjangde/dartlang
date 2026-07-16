import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _nameController = TextEditingController();
  List<dynamic>? _users;
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await context.read<AuthProvider>().authService.getUsers();
      setState(() => _users = users);
    } catch (_) {}
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedUserIds.isEmpty) return;
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.createGroupChat(name, _selectedUserIds.toList());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _selectedUserIds.isNotEmpty ? _createGroup : null,
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add members (${_selectedUserIds.length} selected)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          if (_users == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _users!.length,
                itemBuilder: (context, index) {
                  final user = _users![index] as dynamic;
                  final isSelected = _selectedUserIds.contains(user.id);
                  return CheckboxListTile(
                    value: isSelected,
                    secondary: CircleAvatar(
                      child: Text((user.displayName as String)[0].toUpperCase()),
                    ),
                    title: Text(user.displayName as String),
                    subtitle: Text('@${user.username as String}'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUserIds.add(user.id);
                        } else {
                          _selectedUserIds.remove(user.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
