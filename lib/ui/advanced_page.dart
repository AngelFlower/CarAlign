import 'package:flutter/material.dart';

import '../controller.dart';
import '../format.dart';
import 'diagnostic_page.dart';

/// Ajustes poco habituales: ajuste manual del retraso y demostración.
class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key, required this.controller});

  final AlignController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avanzado')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _ManualSection(c: controller),
            const SizedBox(height: 28),
            _DemoSection(c: controller),
            const SizedBox(height: 28),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: const Text('Diagnóstico y compatibilidad'),
                subtitle: const Text('Qué soporta este teléfono y cómo prepararlo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const DiagnosticPage())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualSection extends StatelessWidget {
  const _ManualSection({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Ajuste manual', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Los cambios se aplican en vivo si la alineación está activa.',
          style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('${fmtMs(c.delayMs)} ms', style: t.displayMedium),
            Text('≈ ${(c.delayMs * AlignController.cmPerMs).toStringAsFixed(1).replaceAll('.', ',')} cm de diferencia',
                style: TextStyle(color: s.onSurfaceVariant)),
            const SizedBox(height: 8),
            Slider(
              value: c.delayMs,
              min: 0,
              max: AlignController.maxMs,
              divisions: 500,
              onChanged: c.setDelay,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filledTonal(
                  iconSize: 28, onPressed: () => c.setDelay(c.delayMs - 0.1), icon: const Icon(Icons.remove)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: () => c.setDelay(c.delayMs - 0.02),
                  icon: const Icon(Icons.chevron_left)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: () => c.setDelay(c.delayMs + 0.02),
                  icon: const Icon(Icons.chevron_right)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                  iconSize: 28, onPressed: () => c.setDelay(c.delayMs + 0.1), icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Retrasar izq.')),
                ButtonSegment(value: false, label: Text('Retrasar der.')),
              ],
              selected: {c.left},
              onSelectionChanged: (v) => c.setLeft(v.first),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: c.active ? s.error : null,
          foregroundColor: c.active ? s.onError : null,
        ),
        onPressed: c.toggle,
        icon: Icon(c.active ? Icons.stop : Icons.play_arrow),
        label: Text(c.active ? 'Detener' : 'Iniciar alineación'),
      ),
    ]);
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final idx = c.demoProfile.clamp(0, c.profiles.isEmpty ? 0 : c.profiles.length - 1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Demostración', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Va de 0 ms a un perfil con música sonando: se oye cómo el escenario se centra.',
              style: TextStyle(color: s.onSurfaceVariant)),
          const SizedBox(height: 12),
          if (c.profiles.isEmpty)
            Text('Guarda un perfil primero (alinea o usa "Guardar actual").',
                style: TextStyle(color: s.onSurfaceVariant))
          else if (c.demoRunning) ...[
            Center(child: Text('${c.demoShown.toStringAsFixed(2)} ms', style: t.displaySmall)),
            Center(child: Text(c.demoLabel)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: c.profiles[idx].delayMs <= 0 ? 0 : (c.demoShown / c.profiles[idx].delayMs).clamp(0.0, 1.0)),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              onPressed: c.stopDemo,
              icon: const Icon(Icons.stop),
              label: const Text('Detener demostración'),
            ),
          ] else ...[
            DropdownButtonFormField<int>(
              key: ValueKey('demo$idx${c.profiles.length}'),
              initialValue: idx,
              decoration: const InputDecoration(labelText: 'Perfil'),
              items: [
                for (var i = 0; i < c.profiles.length; i++)
                  DropdownMenuItem(
                      value: i,
                      child: Text('${c.profiles[i].name} · ${c.profiles[i].delayMs.toStringAsFixed(2)} ms '
                          '${c.profiles[i].left ? 'izq.' : 'der.'}')),
              ],
              onChanged: (v) => c.setDemoProfile(v ?? 0),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Duración'),
              Expanded(
                child: Slider(
                  value: c.demoSeconds,
                  min: 3,
                  max: 40,
                  divisions: 37,
                  label: '${c.demoSeconds.round()} s',
                  onChanged: c.setDemoSeconds,
                ),
              ),
              Text('${c.demoSeconds.round()} s'),
            ]),
            Row(children: [
              const Text('Pasos'),
              Expanded(
                child: Slider(
                  value: c.demoSteps,
                  min: 2,
                  max: 12,
                  divisions: 10,
                  label: '${c.demoSteps.round()}',
                  onChanged: c.setDemoSteps,
                ),
              ),
              Text('${c.demoSteps.round()}'),
            ]),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: () => c.demo(loop: false),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('0 → perfil', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () => c.demo(loop: true),
                  icon: const Icon(Icons.repeat),
                  label: const Text('Ida y vuelta', style: TextStyle(fontSize: 16)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}
