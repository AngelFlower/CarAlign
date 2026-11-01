import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import '../../../controllers/alignment_controller.dart';
import '../../../controllers/system_status_controller.dart';
import '../../../widgets/capture_status_card.dart';
import '../../../widgets/readiness_banner.dart';

/// Switch for capture mode (delaying other music apps) and, when on, its guard status and start/stop card.
class CaptureModeSection extends StatelessWidget {
  const CaptureModeSection({super.key, required this.alignment, required this.status});

  final AlignmentController alignment;
  final SystemStatusController status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.advanced.capture;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr.title, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(tr.description, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: alignment.captureMode,
              onChanged: alignment.setCaptureMode,
              title: Text(tr.switchLabel),
              subtitle: Text(tr.switchHint),
            ),
            if (alignment.captureMode) ...[
              const SizedBox(height: 8),
              ReadinessBanner(status: status),
              const SizedBox(height: 12),
              CaptureStatusCard(alignment: alignment),
            ],
          ],
        ),
      ),
    );
  }
}
