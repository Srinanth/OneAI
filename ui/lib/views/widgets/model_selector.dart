import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'token_badge.dart';

class ModelSelector extends StatelessWidget {
  final String currentProvider;
  final ValueChanged<String> onProviderChanged;

  const ModelSelector({
    super.key,
    required this.currentProvider,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TokenBorder(
      radius: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentProvider,
            icon: Icon(Icons.arrow_drop_down, size: 20, color: Theme.of(context).colorScheme.primary),
            isDense: true,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            items: AppConstants.supportedModels.map((provider) {
              return DropdownMenuItem<String>(
                value: provider,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(provider),
                      size: 16,
                      color: _getColor(provider),
                    ),
                    const SizedBox(width: 8),
                    Text(provider),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onProviderChanged(value);
            },
          ),
        ),
      ),
    );
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