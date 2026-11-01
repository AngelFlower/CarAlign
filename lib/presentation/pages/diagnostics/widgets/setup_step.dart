import 'package:flutter/material.dart';

/// A numbered instruction.
class SetupStep extends StatelessWidget {
  const SetupStep({super.key, required this.number, required this.text});

  final String number, text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: colors.primaryContainer,
            child: Text(number, style: TextStyle(color: colors.onPrimaryContainer, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
