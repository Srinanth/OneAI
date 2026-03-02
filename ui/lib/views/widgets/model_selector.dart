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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentProvider,
          icon: Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.primary),
          isDense: true,
          dropdownColor: theme.colorScheme.surfaceContainer,
          // Custom selected item builder to keep the "closed" view compact
          selectedItemBuilder: (context) {
            return AppConstants.supportedModels.map((provider) {
              return Row(
                children: [
                  Icon(_getIcon(provider), size: 18, color: _getColor(provider)),
                  const SizedBox(width: 8),
                  Text(
                    provider,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: AppConstants.supportedModels.map((provider) {
            // Get the actual model ID mapped to this provider slot
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        cleanModelName,
                        style: TextStyle(
                          fontSize: 10, 
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        ),
                      ),
                    ],
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
      case 'DeepSeek':
        return settings.selectedDeepSeek;
      case 'ChatGPT':
        return settings.selectedOpenRouter;
      case 'Gemini':
      default:
        return settings.selectedGemini;
    }
  }

  IconData _getIcon(String p) {
    switch (p) {
      case 'Gemini': return Icons.auto_awesome;
      case 'DeepSeek': return Icons.psychology;
      case 'ChatGPT': return Icons.bolt;
      default: return Icons.chat_bubble_outline;
    }
  }

  Color _getColor(String p) {
    switch (p) {
      case 'Gemini': return Colors.blue;
      case 'DeepSeek': return Colors.purple;
      case 'ChatGPT': return Colors.orange;
      default: return Colors.grey;
    }
  }
}