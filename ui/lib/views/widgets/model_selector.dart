import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../logic/settings_provider.dart';

class ModelSelector extends ConsumerWidget {
  final String currentProvider;
  final ValueChanged<String> onProviderChanged;

  const ModelSelector({
    super.key,
    required this.currentProvider,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final safeProvider = AppConstants.supportedModels.contains(currentProvider) 
        ? currentProvider 
        : AppConstants.supportedModels.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(maxWidth: 200), 
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeProvider,
          icon: Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.primary),
          isDense: true,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surfaceContainer,
          
          selectedItemBuilder: (context) {
            return AppConstants.supportedModels.map((provider) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(provider), size: 18, color: _getColor(provider)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      provider,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: AppConstants.supportedModels.map((provider) {
            final specificModel = _getMappedModel(provider, settings);
            final cleanModelName = specificModel.split('/').last; 

            return DropdownMenuItem<String>(
              value: provider,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(provider),
                    size: 20,
                    color: _getColor(provider),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          cleanModelName,
                          style: TextStyle(
                            fontSize: 10, 
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onProviderChanged(value);
          },
        ),
      ),
    );
  }

  String _getMappedModel(String provider, SettingsState settings) {
    switch (provider) {
      case 'DeepSeek': return settings.selectedDeepSeek;
      case 'ChatGPT': return settings.selectedOpenRouter;
      case 'Claude': return settings.selectedClaude;
      case 'Grok': return settings.selectedGrok;
      case 'Gemini':
      default: return settings.selectedGemini;
    }
  }

  IconData _getIcon(String p) {
    switch (p) {
      case 'Gemini': return Icons.auto_awesome;
      case 'DeepSeek': return Icons.psychology;
      case 'ChatGPT': return Icons.bolt;
      case 'Claude': return Icons.memory;
      case 'Grok': return Icons.rocket_launch;
      default: return Icons.chat_bubble_outline;
    }
  }

  Color _getColor(String p) {
    switch (p) {
      case 'Gemini': return Colors.blue;
      case 'DeepSeek': return Colors.purple;
      case 'ChatGPT': return Colors.orange;
      case 'Claude': return Colors.teal;
      case 'Grok': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}