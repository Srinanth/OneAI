import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/core/constants.dart';
import '../../logic/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _geminiController = TextEditingController();
  final _deepSeekController = TextEditingController();
  final _openRouterController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _geminiController.dispose();
    _deepSeekController.dispose();
    _openRouterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    
    await notifier.saveProviderSettings('Gemini', _geminiController.text.trim(), ref.read(settingsProvider).selectedGemini);
    await notifier.saveProviderSettings('DeepSeek', _deepSeekController.text.trim(), ref.read(settingsProvider).selectedDeepSeek);
    await notifier.saveProviderSettings('ChatGPT', _openRouterController.text.trim(), ref.read(settingsProvider).selectedOpenRouter);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    if (!_isInitialized) {
      _geminiController.text = settings.geminiKey;
      _deepSeekController.text = settings.deepSeekKey;
      _openRouterController.text = settings.openRouterKey;
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Provider Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          _buildProviderSection(
            'Gemini', _geminiController, settings.selectedGemini, 
            AppConstants.modelFamilies['Gemini']!
          ),
          const SizedBox(height: 16),
          _buildProviderSection(
            'DeepSeek', _deepSeekController, settings.selectedDeepSeek, 
            AppConstants.modelFamilies['DeepSeek']!
          ),
          const SizedBox(height: 16),
          _buildProviderSection(
            'ChatGPT', _openRouterController, settings.selectedOpenRouter, 
            AppConstants.modelFamilies['ChatGPT']!
          ),

          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save All Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(String label, TextEditingController ctrl, String currentModel, List<String> versions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: ctrl, 
              decoration: InputDecoration(labelText: '$label API Key'), 
              obscureText: true
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: currentModel,
              isExpanded: true,
              items: versions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(settingsProvider.notifier).saveProviderSettings(label, ctrl.text, val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}