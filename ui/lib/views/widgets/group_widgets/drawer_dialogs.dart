import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_session.dart';
import '../../../data/models/chat_group.dart';
import '../../../logic/chat_list_provider.dart';

class DrawerDialogs {
  
  static void showCreateGroup(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Group"),
        content: TextField(
          controller: controller, 
          autofocus: true,
          decoration: const InputDecoration(hintText: "Group Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(chatListProvider.notifier).createGroup(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  static void showMoveChat(BuildContext context, WidgetRef ref, ChatSession chat, List<ChatGroup> groups) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Move '${chat.title}' to...", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No groups created yet."),
              ),
            ...groups.map((g) => ListTile(
              leading: const Icon(Icons.folder_outlined, color: Colors.amber),
              title: Text(g.name),
              onTap: () {
                ref.read(chatListProvider.notifier).moveChat(chat.id, g.id);
                Navigator.pop(context); 
              },
            )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Create New Group"),
              onTap: () {
                Navigator.pop(context); 
                showCreateGroup(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}