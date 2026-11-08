import 'package:flutter/material.dart';

import '../theme.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 34, color: c.brandStrong),
        ),
        const SizedBox(height: 20),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(message!, textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
        ],
        if (onAction != null) ...[
          const SizedBox(height: 20),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel ?? 'Try again')),
        ],
      ]),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      MessageView(icon: Icons.wifi_off_rounded, title: 'Couldn’t load this', message: '$error', onAction: onRetry);
}

/// Shown when a room photo is missing or fails to load.
class RoomImage extends StatelessWidget {
  const RoomImage(this.url, {super.key});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.brandSoft, c.surfaceAlt], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Icon(Icons.meeting_room_rounded, size: 40, color: c.brandStrong)),
    );
    if (url == null) return fallback;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
      loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
    );
  }
}
