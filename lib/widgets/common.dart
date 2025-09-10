import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass container
class Glass extends StatelessWidget {
  const Glass({
    required this.child,
    this.borderRadius = 16,
    this.padding,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Status pill widget
class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, Key? key}) : super(key: key);
  final String status;

  Color get _border {
    switch (status.toLowerCase()) {
      case "active":
      case "open":
      case "in_progress":
        return const Color(0xFF6C63FF);
      case "hearing":
        return const Color(0xFF4DD0E1);
      case "closed":
      case "dismissed":
        return Colors.white38;
      default:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
        color: Colors.white.withOpacity(0.06),
      ),
      child: Text(
        status,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Empty state
class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, Key? key}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Date formatter
String fmtDate(DateTime? dt) {
  if (dt == null) return "—";
  final d = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return "${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}";
}
