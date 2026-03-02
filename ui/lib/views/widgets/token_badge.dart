import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_provider.dart';

class TokenBadge extends ConsumerWidget {
  const TokenBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUsage = ref.watch(activeChatProvider.select((s) => s.currentUsage));
    final maxLimit = ref.watch(activeChatProvider.select((s) => s.maxLimit));

    double progress = (maxLimit > 0) ? (currentUsage / maxLimit).clamp(0.0, 1.0) : 0.0;
    
    Color statusColor = Theme.of(context).colorScheme.primary;
    if (progress > 0.9) {
      statusColor = Colors.redAccent;
    } else if (progress > 0.7) {
      statusColor = Colors.orangeAccent;
    }

    return Tooltip(
      message: "$currentUsage / $maxLimit tokens used",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toInt()}% Used",
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ],
      ),
    );
  }
}