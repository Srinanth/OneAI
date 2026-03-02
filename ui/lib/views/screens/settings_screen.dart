import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/core/constants.dart';
import '../../logic/settings_provider.dart';

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
    
    // Save Gemini Slot
    await notifier.saveProviderSettings(
      'Gemini', 
      _useOfficialGemini ? _officialGeminiController.text.trim() : orKey, 
      settings.selectedGemini
    );

    // Save DeepSeek Slot
    await notifier.saveProviderSettings(
      'DeepSeek', 
      _useOfficialDeepSeek ? _officialDeepSeekController.text.trim() : orKey, 
      settings.selectedDeepSeek
    );

    // Save ChatGPT Slot
    await notifier.saveProviderSettings(
      'ChatGPT', 
      _useOfficialChatGPT ? _officialOpenAIController.text.trim() : orKey, 
      settings.selectedOpenRouter
    );

    // Save Claude Slot
    await notifier.saveProviderSettings(
      'Claude', 
      _useOfficialClaude ? _officialClaudeController.text.trim() : orKey, 
      settings.selectedClaude
    );

    // Save Grok Slot
    await notifier.saveProviderSettings(
      'Grok', 
      _useOfficialGrok ? _officialGrokController.text.trim() : orKey, 
      settings.selectedGrok
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
          // --- SECTION 1: OPENROUTER KEY ---
          _buildSectionHeader('OpenRouter Configuration'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow('Unified OpenRouter Key', Icons.hub, Colors.purple),
                  const SizedBox(height: 8),
                  const Text(
                    'Used as the master key for any slot set to "OpenRouter".',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _SecureTextField(
                    controller: _openRouterController,
                    labelText: 'sk-or-v1-...',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: SLOT CONFIGURATION ---
          _buildSectionHeader('Slot Mapping'),
          
          // Gemini Slot
          _buildSlotCard(
            title: 'Google Gemini Slot',
            icon: Icons.auto_awesome, 
            color: Colors.blue,
            isOfficial: _useOfficialGemini,
            onSourceChanged: (val) => setState(() => _useOfficialGemini = val),
            officialController: _officialGeminiController,
            officialLabel: 'Official Gemini API Key',
            models: AppConstants.modelFamilies['Gemini'] ?? [], 
            selectedModel: settings.selectedGemini,
            onModelChanged: (val) {
               ref.read(settingsProvider.notifier).saveProviderSettings('Gemini', _useOfficialGemini ? _officialGeminiController.text : _openRouterController.text, val);
            }
          ),
          const SizedBox(height: 16),

          // DeepSeek Slot
          _buildSlotCard(
            title: 'DeepSeek Slot',
            icon: Icons.psychology, 
            color: Colors.purple,
            isOfficial: _useOfficialDeepSeek,
            onSourceChanged: (val) => setState(() => _useOfficialDeepSeek = val),
            officialController: _officialDeepSeekController,
            officialLabel: 'Official DeepSeek API Key',
            models: AppConstants.modelFamilies['DeepSeek'] ?? [], 
            selectedModel: settings.selectedDeepSeek,
            onModelChanged: (val) {
               ref.read(settingsProvider.notifier).saveProviderSettings('DeepSeek', _useOfficialDeepSeek ? _officialDeepSeekController.text : _openRouterController.text, val);
            }
          ),
          const SizedBox(height: 16),

          // ChatGPT Slot
          _buildSlotCard(
            title: 'ChatGPT Slot',
            icon: Icons.bolt, 
            color: Colors.orange,
            isOfficial: _useOfficialChatGPT,
            onSourceChanged: (val) => setState(() => _useOfficialChatGPT = val),
            officialController: _officialOpenAIController,
            officialLabel: 'Official OpenAI API Key (sk-proj...)',
            models: AppConstants.modelFamilies['ChatGPT'] ?? [],
            selectedModel: settings.selectedOpenRouter,
            onModelChanged: (val) {
               ref.read(settingsProvider.notifier).saveProviderSettings('ChatGPT', _useOfficialChatGPT ? _officialOpenAIController.text : _openRouterController.text, val);
            }
          ),
          const SizedBox(height: 16),

          // Claude Slot
          _buildSlotCard(
            title: 'Claude Slot',
            icon: Icons.memory, // You can use a different icon if preferred
            color: Colors.teal,
            isOfficial: _useOfficialClaude,
            onSourceChanged: (val) => setState(() => _useOfficialClaude = val),
            officialController: _officialClaudeController,
            officialLabel: 'Official Anthropic API Key',
            models: AppConstants.modelFamilies['Claude'] ?? [],
            selectedModel: settings.selectedClaude,
            onModelChanged: (val) {
               ref.read(settingsProvider.notifier).saveProviderSettings('Claude', _useOfficialClaude ? _officialClaudeController.text : _openRouterController.text, val);
            }
          ),
          const SizedBox(height: 16),

          // Grok Slot
          _buildSlotCard(
            title: 'Grok Slot',
            icon: Icons.rocket_launch, 
            color: Colors.blueGrey,
            isOfficial: _useOfficialGrok,
            onSourceChanged: (val) => setState(() => _useOfficialGrok = val),
            officialController: _officialGrokController,
            officialLabel: 'Official xAI API Key',
            models: AppConstants.modelFamilies['Grok'] ?? [],
            selectedModel: settings.selectedGrok,
            onModelChanged: (val) {
               ref.read(settingsProvider.notifier).saveProviderSettings('Grok', _useOfficialGrok ? _officialGrokController.text : _openRouterController.text, val);
            }
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


  Widget _buildSectionHeader(String title) {
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

  Widget _buildHeaderRow(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSlotCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isOfficial,
    required ValueChanged<bool> onSourceChanged,
    required TextEditingController officialController,
    required String officialLabel,
    required List<String> models,
    required String selectedModel,
    required ValueChanged<String> onModelChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(title, icon, color),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildSourceChip("OpenRouter", !isOfficial, () => onSourceChanged(false))),
                const SizedBox(width: 12),
                Expanded(child: _buildSourceChip("Official API", isOfficial, () => onSourceChanged(true))),
              ],
            ),
            const SizedBox(height: 16),

            if (isOfficial) ...[
              _SecureTextField(controller: officialController, labelText: officialLabel),
              const SizedBox(height: 16),
            ],

            _buildModelDropdown(
              value: selectedModel,
              items: models,
              onChanged: onModelChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5
          )
        ),
        child: Text(
          label, 
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            fontSize: 13
          )
        ),
      ),
    );
  }

  Widget _buildModelDropdown({required String value, required List<String> items, required ValueChanged<String> onChanged}) {
    final validValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : null);

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: const InputDecoration(
        labelText: 'Selected Model',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

class _SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const _SecureTextField({required this.controller, required this.labelText});

  @override
  State<_SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<_SecureTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
              tooltip: _obscure ? 'Show Key' : 'Hide Key',
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Key copied to clipboard"), duration: Duration(seconds: 1)),
                );
              },
              tooltip: 'Copy Key',
            ),
          ],
        ),
      ),
    );
  }
}