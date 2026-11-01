import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../i18n/strings.g.dart';
import '../../controllers/diagnostics_controller.dart';
import 'widgets/setup_step.dart';

/// Compatibility report of this phone and the steps to set up another one.
class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  DiagnosticsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    _controller = DiagnosticsController(AppScope.of(context).diagnostics)..loadReport();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _copy(DiagnosticsController c) async {
    await Clipboard.setData(ClipboardData(text: c.shareableReport()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.diagnostics.reportCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tr = t.diagnostics;
    return Scaffold(
      appBar: AppBar(title: Text(tr.title)),
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(tr.intro, style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: SelectableText(c.report ?? tr.loading,
                  style: text.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.4)),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                onPressed: c.testing ? null : c.testMute,
                icon: c.testing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.volume_off),
                label: Text(tr.testMute),
              ),
              OutlinedButton.icon(onPressed: () => _copy(c), icon: const Icon(Icons.copy), label: Text(tr.copyReport)),
              OutlinedButton.icon(onPressed: c.loadReport, icon: const Icon(Icons.refresh), label: Text(tr.refresh)),
              OutlinedButton.icon(
                onPressed: c.openBatterySettings,
                icon: const Icon(Icons.battery_saver),
                label: Text(tr.batterySaver),
              ),
            ]),
            if (c.muteResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.muteWorks ? colors.secondaryContainer : colors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  c.muteWorks
                      ? tr.muteWorks(detail: c.muteResult!)
                      : tr.muteFails(detail: c.muteResult!.isEmpty ? tr.noResponse : c.muteResult!),
                  style: text.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(tr.limitationTitle, style: text.titleLarge),
            const SizedBox(height: 8),
            Text(tr.limitationBody, style: text.bodyMedium),
            const SizedBox(height: 28),
            Text(tr.setupTitle, style: text.titleLarge),
            const SizedBox(height: 8),
            SetupStep(number: '1', text: tr.step1),
            SetupStep(number: '2', text: tr.step2),
            SetupStep(number: '3', text: tr.step3),
            SetupStep(number: '4', text: tr.step4),
            SetupStep(number: '5', text: tr.step5),
            SetupStep(number: '6', text: tr.step6),
            const SizedBox(height: 8),
            Text(tr.footer, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
