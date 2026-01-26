import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _geminiController = TextEditingController();
  final _deepSeekController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _geminiController.dispose();
    _deepSeekController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(settingsProvider.notifier).saveKeys(
      gemini: _geminiController.text.trim(),
      deepSeek: _deepSeekController.text.trim(),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings Saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          if (!_isInitialized) {
            _geminiController.text = settings.geminiKey;
            _deepSeekController.text = settings.deepSeekKey;
            _isInitialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'API Keys',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'These keys are stored locally on your device and sent only to your personal backend.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _geminiController,
                decoration: const InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'Your key here',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.auto_awesome),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _deepSeekController,
                decoration: const InputDecoration(
                  labelText: 'DeepSeek API Key',
                  hintText: 'Your key here',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}