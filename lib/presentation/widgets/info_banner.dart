import 'package:flutter/material.dart';

/// A rounded notice with an icon (or spinner), a title, an optional subtitle and an optional action.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.color,
    required this.onColor,
    required this.title,
    this.subtitle,
    this.icon,
    this.busy = false,
    this.actionLabel,
    this.onAction,
  });

  final Color color, onColor;
  final String title;
  final String? subtitle, actionLabel;
  final IconData? icon;
  final bool busy;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          busy
              ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3))
              : Icon(icon, size: 28, color: onColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: onColor, fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: onColor)),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(64, 48), foregroundColor: onColor),
              onPressed: onAction,
              child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
