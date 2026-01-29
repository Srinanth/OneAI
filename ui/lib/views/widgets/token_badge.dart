import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/chat_provider.dart';

class TokenBadge extends ConsumerWidget {
  const TokenBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(activeChatProvider.select((s) => s.currentUsage));
    final maxLimit = ref.watch(activeChatProvider.select((s) => s.maxLimit));

    double progress = (maxLimit > 0) ? (current / maxLimit).clamp(0.0, 1.0) : 0.0;
    
    Color statusColor = progress > 0.9 
        ? Colors.red 
        : (progress > 0.7 ? Colors.orange : Colors.green);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: statusColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${(progress * 100).toInt()}% Daily Limit", 
          style: TextStyle(
            fontSize: 9, 
            fontWeight: FontWeight.bold,
            color: statusColor
          )
        ),
      ],
    );
  }
}