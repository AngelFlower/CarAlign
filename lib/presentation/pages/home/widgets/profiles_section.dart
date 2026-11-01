import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../i18n/strings.g.dart';
import '../../../controllers/alignment_controller.dart';
import '../../../localization/domain_l10n.dart';

class ProfilesSection extends StatelessWidget {
  const ProfilesSection({super.key, required this.alignment, required this.onSave});

  final AlignmentController alignment;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.home.profiles;
    final profiles = alignment.profiles;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text(tr.title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: onSave,
          icon: const Icon(Icons.add),
          label: Text(tr.saveCurrent),
        ),
      ]),
      if (profiles.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(tr.empty, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        ),
      for (final p in profiles.reversed)
        Dismissible(
          key: ValueKey('${p.name}${p.delay.milliseconds}${p.delay.side}'),
          background: Container(color: colors.errorContainer),
          onDismissed: (_) => alignment.removeProfile(p),
          child: ListTile(
            minTileHeight: 64,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(p.name, style: text.titleMedium),
            subtitle: Text(t.home.status.value(side: p.delay.side.label, ms: formatMs(p.delay.milliseconds))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => alignment.loadProfile(p),
          ),
        ),
      if (profiles.isNotEmpty) Text(tr.hint, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
    ]);
  }
}
