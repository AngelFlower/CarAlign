import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Informe de compatibilidad del teléfono y pasos para prepararlo.
class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  static const _channel = MethodChannel('caralign');
  String _report = 'Cargando…';
  String? _mute;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _report = 'Cargando…');
    final r = await _channel.invokeMethod<String>('diagnostics') ?? 'Sin datos';
    if (mounted) setState(() => _report = r);
  }

  Future<void> _testMute() async {
    setState(() {
      _busy = true;
      _mute = null;
    });
    final r = await _channel.invokeMethod<String>('testMute') ?? 'Sin respuesta';
    if (mounted) {
      setState(() {
        _busy = false;
        _mute = r;
      });
    }
  }

  Future<void> _copy() async {
    final text = '$_report\n== Prueba de silenciado\n${_mute ?? 'sin ejecutar'}\n';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe copiado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Qué soporta este teléfono. Si algo no funciona en otro móvil, copia el informe y compártelo.',
              style: t.bodyLarge?.copyWith(color: s.onSurfaceVariant)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: s.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: SelectableText(_report, style: t.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.4)),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
              onPressed: _busy ? null : _testMute,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.volume_off),
              label: const Text('Probar silenciado'),
            ),
            OutlinedButton.icon(onPressed: _copy, icon: const Icon(Icons.copy), label: const Text('Copiar informe')),
            OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Actualizar')),
            OutlinedButton.icon(
              onPressed: () => _channel.invokeMethod('batteryExempt'),
              icon: const Icon(Icons.battery_saver),
              label: const Text('Ahorro de batería'),
            ),
          ]),
          if (_mute != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _mute!.startsWith('OK') ? s.secondaryContainer : s.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _mute!.startsWith('OK')
                    ? 'El canal para silenciar funciona en este teléfono.\n$_mute'
                    : 'El canal para silenciar NO funciona todavía.\n$_mute',
                style: t.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 28),
          Text('Limitación importante', style: t.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Android no deja que una app normal silencie a otra. CarAlign necesita un canal de ADB '
            'para hacerlo: hay que activarlo con un ordenador (adb tcpip 5555) cada vez que se reinicia el teléfono, '
            'o usar Shizuku. Sin ese canal la app no silencia el audio original y no se activa.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 28),
          Text('Preparar otro teléfono', style: t.titleLarge),
          const SizedBox(height: 8),
          const _Step('1', 'Activa las opciones de desarrollador: Ajustes → Acerca del teléfono → toca 7 veces "Número de compilación".'),
          const _Step('2', 'En Opciones de desarrollador activa "Depuración USB".'),
          const _Step('3',
              'Conecta el teléfono a un ordenador con ADB y ejecuta  adb tcpip 5555 . Hay que repetirlo cada vez que se reinicia el teléfono.'),
          const _Step('4', 'Abre CarAlign. Si aparece "¿Permitir depuración?", acéptalo y marca "Siempre permitir".'),
          const _Step('5',
              'Pulsa "Probar silenciado". Si falla, mira el motivo: algunas marcas piden más ajustes (Xiaomi/Redmi/POCO: '
              '"Depuración USB (ajustes de seguridad)"; Samsung: desactivar el bloqueo de comandos por USB de Auto Blocker).'),
          const _Step('6', 'Pulsa "Ahorro de batería" y permite que CarAlign funcione sin restricciones, para que no la cierren en segundo plano.'),
          const SizedBox(height: 8),
          Text('Sin este canal la app no puede silenciar el audio original y se oiría doble.',
              style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.n, this.text);

  final String n, text;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 13, backgroundColor: s.primaryContainer, child: Text(n, style: TextStyle(color: s.onPrimaryContainer, fontSize: 13))),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}
