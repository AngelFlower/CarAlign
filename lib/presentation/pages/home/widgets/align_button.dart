import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// The main call to action; compact once an alignment already exists.
class AlignButton extends StatelessWidget {
  const AlignButton({super.key, required this.alreadyAligned, required this.onPressed});

  final bool alreadyAligned;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = alreadyAligned ? t.home.align.again : t.home.align.first;
    const icon = Icon(Icons.my_location, size: 28);
    final style = FilledButton.styleFrom(minimumSize: Size.fromHeight(alreadyAligned ? 64 : 88));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        alreadyAligned
            ? FilledButton.tonalIcon(style: style, onPressed: onPressed, icon: icon, label: Text(label))
            : FilledButton.icon(
                style: style.copyWith(
                  textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                onPressed: onPressed,
                icon: icon,
                label: Text(label),
              ),
        const SizedBox(height: 8),
        Text(
          t.home.align.hint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
