import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/alignment_controller.dart';
import '../../../localization/domain_l10n.dart';

/// One line with the delay the player is applying right now.
class DelayChip extends StatelessWidget {
  const DelayChip({super.key, required this.alignment});

  final AlignmentController alignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final has = alignment.hasDelay;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: has ? colors.secondaryContainer : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(has ? Icons.tune : Icons.info_outline, size: 20, color: colors.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              has
                  ? t.home.delay.applied(side: alignment.delay.side.label, ms: formatMs(alignment.delay.milliseconds))
                  : t.home.delay.none,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
