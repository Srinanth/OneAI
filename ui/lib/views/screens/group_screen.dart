import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_session.dart';
import '../../data/models/chat_group.dart';
import '../../data/db/chat.dart';
import '../../logic/chat_list_provider.dart';
import '../../logic/chat_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final ChatGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  List<ChatSession> chats = [];
  bool loading = true;

  final ChatDB _db = ChatDB();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => loading = true);
    final res = await _db.fetchChatSessions(groupId: widget.group.id);
    if (mounted) {
      setState(() {
        chats = res;
        loading = false;
      });
    }
  }

  Future<void> _removeFromGroup(String chatId) async {
    await ref.read(chatListProvider.notifier).moveChat(chatId, null);
    
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Group',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Group?"),
                  content: const Text("Chats inside will be moved to the main list (ungrouped)."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(chatListProvider.notifier).deleteGroup(widget.group.id);
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator())
        : chats.isEmpty 
          ? Center(
              child: Text(
                "No chats in this group.",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline, size: 20),
                  title: Text(chat.title),
                  subtitle: Text(chat.modelId, style: const TextStyle(fontSize: 10)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                    tooltip: "Remove from Group",
                    onPressed: () => _removeFromGroup(chat.id),
                  ),
                  onTap: () {
                    ref.read(activeChatProvider.notifier).loadChat(chat.id);
                    Navigator.pop(context);
                    Navigator.pop(context); 
                  },
                );
              },
            ),
    );
  }
}