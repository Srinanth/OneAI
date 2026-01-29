import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/data/models/chat_state.dart';
import 'package:ui/logic/settings_provider.dart';
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
  String _tempProvider = AppConstants.supportedModels.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUsageWithSettings();
    });
  }

  void _syncUsageWithSettings() {
    final settings = ref.read(settingsProvider);
    final targetModel = _getTargetModel(_tempProvider, settings);
    ref.read(activeChatProvider.notifier).updateModelUsage(targetModel);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(activeChatProvider);
    final settings = ref.watch(settingsProvider);
    
    final isNewChat = chatState.chatId == null;
    
    String currentProvider = _tempProvider;
    if (!isNewChat && chatState.lastUsedModel != null) {
      currentProvider = AppConstants.modelRegistry[chatState.lastUsedModel!]?.provider ?? _tempProvider;
    }

    ref.listen<ChatState>(activeChatProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
      
    return Scaffold(
      drawer: const ChatDrawer(),
      appBar: AppBar(
        title: ModelSelector(
          currentProvider: currentProvider,
          onProviderChanged: (val) {
            setState(() => _tempProvider = val);
            
            final targetModel = _getTargetModel(val, settings);
            ref.read(activeChatProvider.notifier).updateModelUsage(targetModel);
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
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          ),
        ],
      ),
      body: ChatInterface(selectedModelId: currentProvider), 
    );
  }

  String _getTargetModel(String provider, SettingsState settings) {
    switch (provider) {
      case 'DeepSeek': 
        return settings.selectedDeepSeek;
      case 'ChatGPT':
        return settings.selectedOpenRouter;
      case 'Gemini':
      default: 
        return settings.selectedGemini;
    }
  }
}