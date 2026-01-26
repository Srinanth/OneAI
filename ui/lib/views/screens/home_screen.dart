import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_provider.dart';
import '../../core/constants.dart';
import '../widgets/model_selector.dart';
import '../widgets/chat_sidebar.dart'; 
import 'chat_screen.dart';
import 'settings_screen.dart';

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

    return Scaffold(
      drawer: const ChatDrawer(),
      appBar: AppBar(
        title: ModelSelector(
          currentModelId: currentModel,
          onModelChanged: (val) {
             if (isNewChat) {
               setState(() => _tempModelId = val);
             } else {
               setState(() => _tempModelId = val);
             }
          },
        ),
        centerTitle: true,
        actions: [
           IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ChatInterface(
        selectedModelId: currentModel, 
      ),
    );
  }
}