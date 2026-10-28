import 'package:flutter/material.dart';

import '../controller.dart';
import '../format.dart';
import 'advanced_page.dart';
import 'placement_guide.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _c = AlignController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _c.onNotice = (m) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(m), duration: const Duration(seconds: 12), showCloseIcon: true));
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _c.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _c.refresh();
  }

  /// Guía de colocación (si no está oculta) y después la medición.
  Future<void> _align() async {
    if (!_c.hideGuide) {
      final r = await Navigator.of(context).push<({bool start, bool hide})>(
        MaterialPageRoute(builder: (_) => const PlacementGuidePage(firstRun: true)),
      );
      if (r == null || !r.start || !mounted) return;
      if (r.hide) await _c.setHideGuide(true);
    }
    await _c.autoAlign();
  }

  void _openGuide() => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PlacementGuidePage(hideGuide: _c.hideGuide)));

  void _openAdvanced() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdvancedPage(controller: _c)));

  Future<void> _saveProfile() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Guardar perfil'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre (ej. Conductor)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    _c.addProfile(name);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final busy = _c.auto == AutoPhase.countdown || _c.auto == AutoPhase.running;
        return Scaffold(
          appBar: AppBar(
            title: const Text('CarAlign', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: 'Cómo colocar el teléfono',
                iconSize: 28,
                onPressed: _openGuide,
                icon: const Icon(Icons.help_outline),
              ),
              IconButton(
                tooltip: 'Avanzado',
                iconSize: 28,
                onPressed: _openAdvanced,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _Readiness(c: _c),
              const SizedBox(height: 16),
              if (_c.auto == AutoPhase.countdown)
                _Countdown(c: _c)
              else if (_c.auto == AutoPhase.running)
                _Measuring(c: _c)
              else ...[
                if (_c.active || _c.hasDelay) _StatusCard(c: _c),
                if (_c.active || _c.hasDelay) const SizedBox(height: 12),
                _AlignButton(c: _c, onPressed: busy ? null : _align),
                if (_c.auto == AutoPhase.done && _c.result != null) ...[
                  const SizedBox(height: 16),
                  _ResultCard(result: _c.result!),
                ],
              ],
              const SizedBox(height: 28),
              _ProfilesSection(c: _c, onSave: _saveProfile),
            ],
          ),
        );
      },
    );
  }
}

/// Estado de preparación: una línea discreta si todo va bien; llamativo solo si hay algo que hacer.
class _Readiness extends StatelessWidget {
  const _Readiness({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final waiting = !c.guard &&
        (c.guardState == 'auth' || c.guardState == 'starting' || c.guardState == 'shizuku');

    if (!c.mic) {
      return _Banner(
        color: s.errorContainer,
        onColor: s.onErrorContainer,
        icon: Icons.mic_off,
        title: 'Falta el permiso del micrófono',
        sub: 'Sin él no se puede medir.',
        action: 'Dar permiso',
        onAction: c.requestPerms,
      );
    }
    if (c.guard) {
      return Row(children: [
        Icon(Icons.check_circle, size: 20, color: s.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Todo listo · vigilante conectado',
              style: t.bodyLarge?.copyWith(color: s.onSurfaceVariant)),
        ),
      ]);
    }
    if (waiting) {
      return _Banner(
        color: s.surfaceContainerHighest,
        onColor: s.onSurface,
        busy: true,
        title: switch (c.guardState) {
          'auth' => 'Conectando el vigilante…',
          'shizuku' => 'Esperando la autorización de Shizuku…',
          _ => 'Iniciando el vigilante…',
        },
        sub: switch (c.guardState) {
          'auth' => 'Si el teléfono muestra "¿Permitir depuración?", acéptalo y marca "Siempre permitir".',
          'shizuku' => 'Acepta el aviso de Shizuku para que CarAlign pueda arrancar su vigilante.',
          _ => null,
        },
      );
    }
    return _Banner(
      color: s.errorContainer,
      onColor: s.onErrorContainer,
      icon: Icons.warning_amber_rounded,
      title: 'El vigilante de audio está apagado',
      sub: c.guardDetail.isNotEmpty
          ? c.guardDetail
          : 'Sin él no se silencia el original ni se inicia la captura sola.',
      action: 'Reintentar',
      onAction: c.guardEnsure,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.onColor,
    required this.title,
    this.sub,
    this.icon,
    this.busy = false,
    this.action,
    this.onAction,
  });

  final Color color, onColor;
  final String title;
  final String? sub, action;
  final IconData? icon;
  final bool busy;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        busy
            ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3))
            : Icon(icon, size: 28, color: onColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.titleMedium?.copyWith(color: onColor, fontWeight: FontWeight.w700)),
            if (sub != null) Text(sub!, style: t.bodyMedium?.copyWith(color: onColor)),
          ]),
        ),
        if (action != null)
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48), foregroundColor: onColor),
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}

/// Alineación activa (con Detener) o detenida (con Iniciar).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final on = c.active;
    final bg = on ? s.primaryContainer : s.surfaceContainerHigh;
    final fg = on ? s.onPrimaryContainer : s.onSurface;
    final side = c.left ? 'Izquierdo' : 'Derecho';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(on ? Icons.graphic_eq : Icons.pause_circle_outline, color: fg, size: 28),
          const SizedBox(width: 10),
          Text(on ? 'Alineación activa' : 'Alineación detenida',
              style: t.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text('$side +${fmtMs(c.delayMs)} ms',
            style: t.displaySmall?.copyWith(color: fg, fontWeight: FontWeight.w800)),
        Text(on ? 'Procesando el audio del teléfono' : 'Último ajuste guardado',
            style: t.bodyLarge?.copyWith(color: fg)),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(64),
            backgroundColor: on ? s.error : s.primary,
            foregroundColor: on ? s.onError : s.onPrimary,
          ),
          onPressed: c.toggle,
          icon: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 30),
          label: Text(on ? 'Detener' : 'Iniciar'),
        ),
      ]),
    );
  }
}

class _AlignButton extends StatelessWidget {
  const _AlignButton({required this.c, required this.onPressed});

  final AlignController c;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final again = c.active || c.hasDelay;
    final label = c.auto == AutoPhase.done || again ? 'Volver a alinear' : 'Alinear automáticamente';
    final icon = Icon(Icons.my_location, size: 28);
    final style = FilledButton.styleFrom(minimumSize: Size.fromHeight(again ? 64 : 88));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      again
          ? FilledButton.tonalIcon(style: style, onPressed: onPressed, icon: icon, label: Text(label))
          : FilledButton.icon(
              style: style.copyWith(textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
              onPressed: onPressed,
              icon: icon,
              label: Text(label)),
      const SizedBox(height: 8),
      Text('Mide con el micrófono del teléfono, aplica el retraso y lo verifica (~1 min).',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
    ]);
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(color: s.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        Text('${c.countdown}',
            style: t.displayLarge?.copyWith(
                fontSize: 128, fontWeight: FontWeight.w800, color: s.onPrimaryContainer, height: 1)),
        const SizedBox(height: 8),
        Text('Deja el teléfono en su sitio',
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(color: s.onPrimaryContainer, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Micrófono hacia el frente y quieto',
            textAlign: TextAlign.center, style: t.titleMedium?.copyWith(color: s.onPrimaryContainer)),
      ]),
    );
  }
}

class _Measuring extends StatelessWidget {
  const _Measuring({required this.c});

  final AlignController c;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: s.primaryContainer, borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        Icon(Icons.graphic_eq, size: 56, color: s.onPrimaryContainer),
        const SizedBox(height: 12),
        Text('${c.phase}…',
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(color: s.onPrimaryContainer, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: c.frac > 0 ? c.frac : null, minHeight: 14),
        ),
        const SizedBox(height: 16),
        Text('No muevas el teléfono', style: t.titleMedium?.copyWith(color: s.onPrimaryContainer)),
      ]),
    );
  }
}

/// Resultado en lenguaje claro; los datos técnicos van plegados en "Detalles".
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final Map<String, dynamic> result;

  String _bandsText(Map<String, dynamic> m) {
    String f(String k) => m[k] == null ? '—' : '${((m[k] as num) * 1000).round() / 1000}';
    return 'graves ${f('graves')} · medios ${f('medios')} · agudos ${f('agudos')} ms';
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final r = result;
    final status = r['status'] as String? ?? 'FAIL';
    final apply = r['apply'] == true;
    final (color, icon) = switch (status) {
      'OK' => (s.primary, Icons.check_circle),
      'WARN' => (const Color(0xFFB26A00), Icons.warning_rounded),
      _ => (s.error, Icons.error),
    };
    final left = (r['delayLeftMs'] as num? ?? 0) > 0;
    final ms = ((left ? r['delayLeftMs'] : r['delayRightMs']) as num? ?? 0).toDouble();
    final msgs = (r['messages'] as List?)?.cast<String>() ?? [];
    final src = AudioSource.parse(r['out'] as String?);
    final String sourceLine = switch (src.name) {
      'Android Auto' || 'Bluetooth' => 'Medido a través de ${src.name}',
      'Altavoz del teléfono' => 'Medido con el altavoz del teléfono (no el del coche)',
      'USB' => 'Medido a través de USB',
      _ => src.raw.isEmpty ? '' : 'Origen de audio no reconocido',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: s.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              apply
                  ? 'Retrasar el ${left ? 'izquierdo' : 'derecho'} ${fmtMs(ms)} ms'
                  : 'No se aplicó ningún cambio',
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        if (sourceLine.isNotEmpty)
          Text(sourceLine, style: t.bodyLarge?.copyWith(color: s.onSurfaceVariant)),
        if (!apply || status != 'OK')
          for (final m in msgs)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text('• $m', style: t.bodyLarge)),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: const Text('Detalles'),
            children: [
              if (apply)
                _Detail('Verificado: residuo ${(r['residualUs'] as num? ?? 0).toStringAsFixed(0)} µs · '
                    'dispersión ${(r['sigmaUs'] as num? ?? 0).toStringAsFixed(0)} µs · '
                    '${r['valid']}/8 válidas · banda ${r['band']}'),
              if (status == 'OK')
                for (final m in msgs) _Detail('• $m'),
              if (r['bandsMs'] != null)
                _Detail('Sin retraso, R−L por banda: ${_bandsText(r['bandsMs'] as Map<String, dynamic>)}'),
              _Detail('Salida: ${src.name}${src.raw.isEmpty ? '' : ' (${src.raw})'}'),
              _Detail('Micrófono: ${r['in'] ?? '?'}'),
              _Detail('Ruido: ${(r['noiseDbfs'] as num? ?? 0).toStringAsFixed(0)} dBFS'),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
    );
  }
}

class _ProfilesSection extends StatelessWidget {
  const _ProfilesSection({required this.c, required this.onSave});

  final AlignController c;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('Perfiles', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: onSave,
          icon: const Icon(Icons.add),
          label: const Text('Guardar actual'),
        ),
      ]),
      if (c.profiles.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Sin perfiles todavía. Cada alineación automática guarda uno.',
              style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
        ),
      for (final p in c.profiles.reversed)
        Dismissible(
          key: ValueKey('${p.name}${p.delayMs}${p.left}'),
          background: Container(color: s.errorContainer),
          onDismissed: (_) => c.removeProfile(p),
          child: ListTile(
            minTileHeight: 64,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(p.name, style: t.titleMedium),
            subtitle: Text('${p.left ? 'Izquierdo' : 'Derecho'} +${fmtMs(p.delayMs)} ms'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => c.loadProfile(p),
          ),
        ),
      if (c.profiles.isNotEmpty)
        Text('Toca un perfil para aplicarlo; desliza para borrarlo.',
            style: t.bodySmall?.copyWith(color: s.onSurfaceVariant)),
    ]);
  }
}
