import 'package:flutter/material.dart';
import '../../core/constants.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentProvider,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
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