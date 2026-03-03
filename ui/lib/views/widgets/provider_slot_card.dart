import 'package:flutter/material.dart';
import 'secure_text_field.dart';

class ProviderSlotCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isOfficial;
  final ValueChanged<bool> onSourceChanged;
  final TextEditingController officialController;
  final String officialLabel;
  final List<String> models;
  final String selectedModel;
  final ValueChanged<String> onModelChanged;

  const ProviderSlotCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isOfficial,
    required this.onSourceChanged,
    required this.officialController,
    required this.officialLabel,
    required this.models,
    required this.selectedModel,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: _buildSourceChip(context, "OpenRouter", !isOfficial, () => onSourceChanged(false))),
                const SizedBox(width: 12),
                Expanded(child: _buildSourceChip(context, "Official API", isOfficial, () => onSourceChanged(true))),
              ],
            ),
            const SizedBox(height: 16),

            if (isOfficial) ...[
              SecureTextField(controller: officialController, labelText: officialLabel),
              const SizedBox(height: 16),
            ],

            _buildModelDropdown(),
          ],
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

  Widget _buildSourceChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildModelDropdown() {
    final validValue = models.contains(selectedModel) ? selectedModel : (models.isNotEmpty ? models.first : null);

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: const InputDecoration(
        labelText: 'Selected Model',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: models.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (val) {
        if (val != null) onModelChanged(val);
      },
    );
  }
}