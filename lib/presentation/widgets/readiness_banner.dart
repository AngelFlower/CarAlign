import 'package:flutter/material.dart';

import '../../domain/entities/guard_status.dart';
import '../../i18n/strings.g.dart';
import '../controllers/system_status_controller.dart';
import '../localization/domain_l10n.dart';
import 'info_banner.dart';

/// Readiness: one discreet line when all is well; a prominent banner only when something needs doing.
/// Without [showGuard] only the microphone permission is checked.
class ReadinessBanner extends StatelessWidget {
  const ReadinessBanner({super.key, required this.status, this.showGuard = true});

  final SystemStatusController status;

  /// The guard only matters in capture mode; the microphone permission always does.
  final bool showGuard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final guard = status.guard;
    final tr = t.home.readiness;

    if (!status.hasMicrophone) {
      return InfoBanner(
        color: colors.errorContainer,
        onColor: colors.onErrorContainer,
        icon: Icons.mic_off,
        title: tr.micMissingTitle,
        subtitle: tr.micMissingSubtitle,
        actionLabel: tr.grantPermission,
        onAction: status.requestPermissions,
      );
    }
    if (!showGuard) return const SizedBox.shrink();
    if (guard.alive) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tr.ready, style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
          ),
        ],
      );
    }
    if (guard.isConnecting) {
      return InfoBanner(
        color: colors.surfaceContainerHighest,
        onColor: colors.onSurface,
        busy: true,
        title: switch (guard.state) {
          GuardState.auth => tr.connectingTitle,
          GuardState.shizuku => tr.shizukuTitle,
          _ => tr.startingTitle,
        },
        subtitle: switch (guard.state) {
          GuardState.auth => tr.connectingSubtitle,
          GuardState.shizuku => tr.shizukuSubtitle,
          _ => null,
        },
      );
    }
    return InfoBanner(
      color: colors.errorContainer,
      onColor: colors.onErrorContainer,
      icon: Icons.warning_amber_rounded,
      title: tr.offTitle,
      subtitle: guard.detail?.text ?? tr.offSubtitle,
      actionLabel: tr.retry,
      onAction: status.ensureGuard,
    );
  }
}
