import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Text(
            '$secondsLeft',
            style: text.displayLarge?.copyWith(
              fontSize: 128,
              fontWeight: FontWeight.w800,
              color: colors.onPrimaryContainer,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.home.countdown.title,
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            t.home.countdown.subtitle,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(color: colors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
