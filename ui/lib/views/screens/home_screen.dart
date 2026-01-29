import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/data/models/chat_state.dart';
import '../../logic/chat_provider.dart';
import '../../core/constants.dart';
import '../widgets/model_selector.dart';
import '../widgets/chat_sidebar.dart'; 
import 'chat_screen.dart';
import 'settings_screen.dart';
import '../widgets/token_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _tempModelId = AppConstants.supportedModels.first;

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(activeChatProvider);
    final isNewChat = chatState.chatId == null;
    final currentModel = isNewChat ? _tempModelId : (chatState.lastUsedModel ?? _tempModelId);

    ref.listen<ChatState>(activeChatProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
      
    return Scaffold(
      drawer: const ChatDrawer(),
      appBar: AppBar(
        title: ModelSelector(
          currentModelId: currentModel,
          onModelChanged: (val) {
            setState(() => _tempModelId = val);
            ref.read(activeChatProvider.notifier).updateModelUsage(val);
          },
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(child: TokenBadge()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ChatInterface(selectedModelId: currentModel),
    );
  }
}