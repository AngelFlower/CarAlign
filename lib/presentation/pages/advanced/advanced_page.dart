import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../i18n/strings.g.dart';
import '../diagnostics/diagnostics_page.dart';
import 'widgets/capture_mode_section.dart';
import 'widgets/demo_section.dart';
import 'widgets/manual_adjust_section.dart';

/// Rarely needed tools: manual delay adjustment and the demo.
class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.advanced.title)),
      body: ListenableBuilder(
        listenable: Listenable.merge([deps.alignment, deps.demo, deps.status]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            ManualAdjustSection(alignment: deps.alignment),
            const SizedBox(height: 28),
            DemoSection(demo: deps.demo),
            const SizedBox(height: 28),
            CaptureModeSection(alignment: deps.alignment, status: deps.status),
            const SizedBox(height: 28),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: Text(t.advanced.diagnostics.title),
                subtitle: Text(t.advanced.diagnostics.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DiagnosticsPage())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
