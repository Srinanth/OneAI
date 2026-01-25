// this page works like in normal ai apps, starts with a new chat screen but the chat is created only if we text there, otherwise take old chats
// from side bar


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart'; // We will create this next

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // The AuthGate in main.dart will automatically handle the redirect to Login
  }

  void _createNewChat(BuildContext context) {
    // Navigate to ChatScreen with no ID (New Session)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _openChat(BuildContext context, String chatId, String title) {
    // Navigate to ChatScreen with existing ID
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId, initialTitle: title)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Watch the chat_list_provider here later
    // final chatListAsync = ref.watch(chatListProvider); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _buildPlaceholderList(context), // Temporarily using static data
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewChat(context),
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Temporary Widget to visualize the layout before we hook up the backend
  Widget _buildPlaceholderList(BuildContext context) {
    // Mock Data
    final mockChats = [
      {'id': '1', 'title': 'Project Alpha Brainstorm', 'date': 'Just now', 'model': 'Gemini'},
      {'id': '2', 'title': 'Flutter Architecture Refactor', 'date': 'Yesterday', 'model': 'DeepSeek'},
      {'id': '3', 'title': 'Recipe Ideas', 'date': 'Mon', 'model': 'Gemini'},
    ];

    if (mockChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockChats.length,
      itemBuilder: (context, index) {
        final chat = mockChats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              chat['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      chat['model']!,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(chat['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () => _openChat(context, chat['id']!, chat['title']!),
          ),
        );
      },
    );
  }
}