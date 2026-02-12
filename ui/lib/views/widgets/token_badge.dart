import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/logic/chat_provider.dart';

class TokenBorder extends ConsumerWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;

  const TokenBorder({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.strokeWidth = 2.5,
  });

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
      triggerMode: TooltipTriggerMode.longPress,
      child: CustomPaint(
        foregroundPainter: _BorderProgressPainter(
          progress: progress,
          color: statusColor,
          strokeWidth: strokeWidth,
          radius: radius,
        ),
        child: child,
      ),
    );
  }
}

class _BorderProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double radius;

  _BorderProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    
    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics().first;
    final extractPath = metrics.extractPath(
      0.0, 
      metrics.length * progress,
      startWithMoveTo: true,
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}