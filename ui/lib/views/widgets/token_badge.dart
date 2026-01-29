import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/logic/chat_provider.dart';

class TokenBadge extends ConsumerWidget {
  const TokenBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(activeChatProvider.select((s) => s.currentUsage));
    final maxLimit = ref.watch(activeChatProvider.select((s) => s.maxLimit));

    double progress = (maxLimit > 0) ? (current / maxLimit).clamp(0.0, 1.0) : 0.0;
    Color statusColor = progress > 0.9 ? Colors.red : (progress > 0.7 ? Colors.orange : Colors.blueAccent);

    return Tooltip(
      message: "$current / $maxLimit tokens used today",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
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