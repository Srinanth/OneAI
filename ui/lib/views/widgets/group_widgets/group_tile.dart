import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_group.dart';
import '../../../logic/chat_list_provider.dart';
import '../../screens/group_screen.dart';

class GroupTile extends ConsumerWidget {
  final ChatGroup group;

  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.folder_outlined, color: Colors.amber),
      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 16),
        itemBuilder: (ctx) => [
          const PopupMenuItem(value: 'delete', child: Text("Delete Group")),
        ],
        onSelected: (val) {
          if (val == 'delete') {
            ref.read(chatListProvider.notifier).deleteGroup(group.id);
          }
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)),
        );
      },
    );
  }
}