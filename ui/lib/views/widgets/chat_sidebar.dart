import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_list_provider.dart';
import '../../logic/chat_provider.dart';
import '../../logic/auth_provider.dart';
import '../widgets/rename_dialog.dart';

class ChatDrawer extends ConsumerWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(activeChatProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
          Expanded(
            child: chatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (chats) {
                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      'No history yet.',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.read(chatListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
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
                          trailing: PopupMenuButton<String>(
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
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: ListTile(
                                  leading: Icon(Icons.edit, size: 20),
                                  title: Text('Rename'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, size: 20, color: Colors.red),
                                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (!isActive) {
                               ref.read(activeChatProvider.notifier).loadChat(chat.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.logout, size: 20, color: Colors.grey),
              title: const Text('Sign Out', style: TextStyle(fontSize: 14)),
              onTap: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}