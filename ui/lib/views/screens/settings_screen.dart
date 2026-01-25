// A simple form interface that allows the user to input or update their personalized API keys (Gemini/DeepSeek) and User ID,
// which are then saved via the session_provider for future requests.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _geminiController;
  late TextEditingController _deepSeekController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _geminiController = TextEditingController(text: settings.geminiKey);
    _deepSeekController = TextEditingController(text: settings.deepSeekKey);
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
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
          
          // Gemini Input
          TextField(
            controller: _geminiController,
            decoration: const InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'AIzaSy...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.auto_awesome),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),

          // DeepSeek Input
          TextField(
            controller: _deepSeekController,
            decoration: const InputDecoration(
              labelText: 'DeepSeek API Key',
              hintText: 'sk-...',
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
      ),
    );
  }
}