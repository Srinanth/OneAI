import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ModelSelector extends StatelessWidget {
  final String currentModelId;
  final ValueChanged<String> onModelChanged;

  const ModelSelector({
    super.key,
    required this.currentModelId,
    required this.onModelChanged,
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
          value: currentModelId,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          items: AppConstants.supportedModels.map((modelId) {
            return DropdownMenuItem(
              value: modelId,
              child: Row(
                children: [
                  Icon(
                    modelId.contains('gemini') ? Icons.auto_awesome : Icons.psychology,
                    size: 16,
                    color: modelId.contains('gemini') ? Colors.blue : Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(_formatModelName(modelId)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onModelChanged(value);
          },
        ),
      ),
    );
  }

  String _formatModelName(String id) {
    if (id.contains('gemini')) return 'Gemini';
    if (id.contains('deepseek')) return 'DeepSeek';
    return id;
  }
}