import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_list_provider.dart';
import '../../logic/chat_provider.dart';
import '../../logic/auth_provider.dart';
import './group_widgets/drawer_dialogs.dart';
import './group_widgets/group_tile.dart';
import './group_widgets/chat_tile.dart';

class ChatDrawer extends ConsumerWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listStateAsync = ref.watch(chatListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildNewChatHeader(context, ref, colorScheme),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),

          Expanded(
            child: listStateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (state) {
                if (state.chats.isEmpty && state.groups.isEmpty) {
                  return Center(
                    child: Text('No history yet.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.read(chatListProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (state.groups.isNotEmpty) ...[
                        _buildSectionHeader(context, ref, "Groups"),
                        ...state.groups.map((group) => GroupTile(group: group)),
                        const Divider(indent: 16, endIndent: 16),
                      ] else 
                        _buildSectionHeader(context, ref, "Groups"),

                      _buildSectionHeader(context, ref, "Recent Chats", showAdd: false),
                      ...state.chats.map((chat) => ChatTile(chat: chat, availableGroups: state.groups)),
                    ],
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.5)),
          _buildSignOutFooter(ref),
        ],
      ),
    );
  }

  Widget _buildNewChatHeader(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    return SafeArea(
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, WidgetRef ref, String title, {bool showAdd = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          if (showAdd)
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => DrawerDialogs.showCreateGroup(context, ref),
                tooltip: "Create Group",
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignOutFooter(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.logout, size: 20, color: Colors.grey),
        title: const Text('Sign Out', style: TextStyle(fontSize: 14)),
        onTap: () => ref.read(authControllerProvider.notifier).signOut(),
      ),
    );
  }
}