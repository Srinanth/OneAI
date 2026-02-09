import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_session.dart';
import '../../../data/models/chat_group.dart';
import '../../../logic/chat_list_provider.dart';
import '../../../logic/chat_provider.dart';
import '../../widgets/rename_dialog.dart';
import 'drawer_dialogs.dart';

class ChatTile extends ConsumerWidget {
  final ChatSession chat;
  final List<ChatGroup> availableGroups;

  const ChatTile({
    super.key, 
    required this.chat, 
    required this.availableGroups
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = ref.watch(activeChatProvider.select((s) => s.chatId == chat.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        dense: true,
        selected: isActive,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        selectedColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          chat.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400
          ),
        ),
        subtitle: Text(
          chat.modelId,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
        onLongPress: () => DrawerDialogs.showMoveChat(context, ref, chat, availableGroups),
        
        trailing: _buildPopupMenu(context, ref),
        onTap: () {
          Navigator.pop(context);
          if (!isActive) {
            ref.read(activeChatProvider.notifier).loadChat(chat.id);
          }
        },
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (action) async {
        if (action == 'rename') {
          final newTitle = await showDialog<String>(
            context: context,
            builder: (_) => RenameDialog(currentTitle: chat.title),
          );
          if (newTitle != null && newTitle.isNotEmpty) {
            ref.read(chatListProvider.notifier).renameChat(chat.id, newTitle);
          }
        } else if (action == 'delete') {
          ref.read(chatListProvider.notifier).deleteChat(chat.id);
        } else if (action == 'move') {
          DrawerDialogs.showMoveChat(context, ref, chat, availableGroups);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Rename'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'move', child: ListTile(leading: Icon(Icons.folder_open, size: 18), title: Text('Move to Group'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }
}