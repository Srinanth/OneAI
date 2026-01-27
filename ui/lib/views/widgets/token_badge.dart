import 'package:flutter/material.dart';

class TokenBadge extends StatelessWidget {
  final int current;
  final int max;

  const TokenBadge({super.key, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    double progress = (current / max).clamp(0.0, 1.0);
    Color statusColor = progress > 0.9 ? Colors.red : (progress > 0.7 ? Colors.orange : Colors.green);

    return Column(
      children: [
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: statusColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Text("${(progress * 100).toInt()}% Limit", style: TextStyle(fontSize: 10, color: statusColor)),
      ],
    );
  }
}