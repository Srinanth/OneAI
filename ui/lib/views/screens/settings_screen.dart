import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/core/constants.dart';
import '../../logic/settings_provider.dart';
import '../widgets/secure_text_field.dart';
import '../widgets/provider_slot_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _openRouterController = TextEditingController();

  final _officialGeminiController = TextEditingController();
  final _officialOpenAIController = TextEditingController();
  final _officialDeepSeekController = TextEditingController();
  final _officialClaudeController = TextEditingController();
  final _officialGrokController = TextEditingController();
  
  bool _useOfficialGemini = true;
  bool _useOfficialChatGPT = false; 
  bool _useOfficialDeepSeek = false;
  bool _useOfficialClaude = false;
  bool _useOfficialGrok = false;
  
  bool _isInitialized = false;

  @override
  void dispose() {
    _openRouterController.dispose();
    _officialGeminiController.dispose();
    _officialOpenAIController.dispose();
    _officialDeepSeekController.dispose();
    _officialClaudeController.dispose();
    _officialGrokController.dispose();
    super.dispose();
  }

  void _initSlotState(String savedKey, TextEditingController officialCtrl, void Function(bool) setOfficial) {
    if (savedKey.startsWith('sk-or-v1')) {
      setOfficial(false);
      if (_openRouterController.text.isEmpty) {
        _openRouterController.text = savedKey;
      }
    } else if (savedKey.isNotEmpty) {
      setOfficial(true);
      officialCtrl.text = savedKey;
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);
    final orKey = _openRouterController.text.trim();
    
    await notifier.saveProviderSettings(
      'Gemini', _useOfficialGemini ? _officialGeminiController.text.trim() : orKey, settings.selectedGemini
    );
    await notifier.saveProviderSettings(
      'DeepSeek', _useOfficialDeepSeek ? _officialDeepSeekController.text.trim() : orKey, settings.selectedDeepSeek
    );
    await notifier.saveProviderSettings(
      'ChatGPT', _useOfficialChatGPT ? _officialOpenAIController.text.trim() : orKey, settings.selectedOpenRouter
    );
    await notifier.saveProviderSettings(
      'Claude', _useOfficialClaude ? _officialClaudeController.text.trim() : orKey, settings.selectedClaude
    );
    await notifier.saveProviderSettings(
      'Grok', _useOfficialGrok ? _officialGrokController.text.trim() : orKey, settings.selectedGrok
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    if (!_isInitialized) {
      _initSlotState(settings.geminiKey, _officialGeminiController, (val) => _useOfficialGemini = val);
      _initSlotState(settings.deepSeekKey, _officialDeepSeekController, (val) => _useOfficialDeepSeek = val);
      _initSlotState(settings.openRouterKey, _officialOpenAIController, (val) => _useOfficialChatGPT = val);
      _initSlotState(settings.claudeKey, _officialClaudeController, (val) => _useOfficialClaude = val);
      _initSlotState(settings.grokKey, _officialGrokController, (val) => _useOfficialGrok = val);
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'OpenRouter Configuration'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.hub, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Unified OpenRouter Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Used as the master key for any slot set to "OpenRouter".',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SecureTextField(
                    controller: _openRouterController,
                    labelText: 'sk-or-v1-...',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Slot Mapping'),
          
          ProviderSlotCard(
            title: 'Google Gemini Slot', icon: Icons.auto_awesome, color: Colors.blue,
            isOfficial: _useOfficialGemini,
            onSourceChanged: (val) => setState(() => _useOfficialGemini = val),
            officialController: _officialGeminiController, officialLabel: 'Official Gemini API Key',
            models: AppConstants.modelFamilies['Gemini'] ?? [], selectedModel: settings.selectedGemini,
            onModelChanged: (val) => ref.read(settingsProvider.notifier).saveProviderSettings('Gemini', _useOfficialGemini ? _officialGeminiController.text : _openRouterController.text, val)
          ),
          const SizedBox(height: 16),

          ProviderSlotCard(
            title: 'DeepSeek Slot', icon: Icons.psychology, color: Colors.purple,
            isOfficial: _useOfficialDeepSeek,
            onSourceChanged: (val) => setState(() => _useOfficialDeepSeek = val),
            officialController: _officialDeepSeekController, officialLabel: 'Official DeepSeek API Key',
            models: AppConstants.modelFamilies['DeepSeek'] ?? [], selectedModel: settings.selectedDeepSeek,
            onModelChanged: (val) => ref.read(settingsProvider.notifier).saveProviderSettings('DeepSeek', _useOfficialDeepSeek ? _officialDeepSeekController.text : _openRouterController.text, val)
          ),
          const SizedBox(height: 16),

          ProviderSlotCard(
            title: 'ChatGPT Slot', icon: Icons.bolt, color: Colors.orange,
            isOfficial: _useOfficialChatGPT,
            onSourceChanged: (val) => setState(() => _useOfficialChatGPT = val),
            officialController: _officialOpenAIController, officialLabel: 'Official OpenAI API Key (sk-proj...)',
            models: AppConstants.modelFamilies['ChatGPT'] ?? [], selectedModel: settings.selectedOpenRouter,
            onModelChanged: (val) => ref.read(settingsProvider.notifier).saveProviderSettings('ChatGPT', _useOfficialChatGPT ? _officialOpenAIController.text : _openRouterController.text, val)
          ),
          const SizedBox(height: 16),

          ProviderSlotCard(
            title: 'Claude Slot', icon: Icons.memory, color: Colors.teal,
            isOfficial: _useOfficialClaude,
            onSourceChanged: (val) => setState(() => _useOfficialClaude = val),
            officialController: _officialClaudeController, officialLabel: 'Official Anthropic API Key',
            models: AppConstants.modelFamilies['Claude'] ?? [], selectedModel: settings.selectedClaude,
            onModelChanged: (val) => ref.read(settingsProvider.notifier).saveProviderSettings('Claude', _useOfficialClaude ? _officialClaudeController.text : _openRouterController.text, val)
          ),
          const SizedBox(height: 16),

          ProviderSlotCard(
            title: 'Grok Slot', icon: Icons.rocket_launch, color: Colors.blueGrey,
            isOfficial: _useOfficialGrok,
            onSourceChanged: (val) => setState(() => _useOfficialGrok = val),
            officialController: _officialGrokController, officialLabel: 'Official xAI API Key',
            models: AppConstants.modelFamilies['Grok'] ?? [], selectedModel: settings.selectedGrok,
            onModelChanged: (val) => ref.read(settingsProvider.notifier).saveProviderSettings('Grok', _useOfficialGrok ? _officialGrokController.text : _openRouterController.text, val)
          ),

          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            icon: const Icon(Icons.save),
            label: const Text('Save All Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }
}