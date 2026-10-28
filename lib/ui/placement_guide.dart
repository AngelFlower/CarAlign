import 'package:flutter/material.dart';

/// Guía de colocación del teléfono. Con [firstRun] muestra la casilla "No volver a mostrar" y devuelve
/// true si el usuario pulsa "Entendido, empezar".
class PlacementGuidePage extends StatefulWidget {
  const PlacementGuidePage({super.key, this.firstRun = false, this.hideGuide = false});

  final bool firstRun;
  final bool hideGuide;

  @override
  State<PlacementGuidePage> createState() => _PlacementGuidePageState();
}

class _PlacementGuidePageState extends State<PlacementGuidePage> {
  late bool _hide = widget.hideGuide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    const steps = [
      (Icons.headphones, 'Donde va la cabeza',
          'A la altura de los oídos y centrado entre ambos, no pegado a la puerta. '
              'Un centímetro de diferencia ya cambia el resultado, así que colócalo siempre igual.'),
      (Icons.mic, 'Micrófono hacia el frente',
          'El borde de abajo del teléfono (donde está el micrófono) apunta al parabrisas. '
              'No lo tapes con la mano ni con una funda gruesa.'),
      (Icons.pan_tool_alt_outlined, 'Quieto y firme',
          'Apoyado o en un soporte, nunca en la mano. Si se mueve, la medición se descarta.'),
    ];
    const car = [
      'Ventanas cerradas y nadie hablando',
      'Motor apagado o estable',
      'Volumen del coche en medio',
      'Fader totalmente hacia adelante (traseros apagados)',
      'Balance al centro y tonos en plano',
      'Conectado por Android Auto o Bluetooth, con la música en pausa',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo colocar el teléfono')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _Figure(
              caption: 'Vista desde arriba: el teléfono ocupa el lugar de la cabeza.',
              child: CustomPaint(painter: _TopViewPainter(scheme, t.brightness == Brightness.dark)),
            ),
            const SizedBox(height: 12),
            _Figure(
              caption: 'Vista de lado: a la altura de los oídos, tumbado, con el micrófono hacia adelante.',
              child: CustomPaint(painter: _SideViewPainter(scheme, t.brightness == Brightness.dark)),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Icon(steps[i].$1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${i + 1}. ${steps[i].$2}',
                          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(steps[i].$3, style: t.textTheme.bodyLarge),
                    ]),
                  ),
                ]),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('En el coche', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final c in car)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.check_circle_outline, size: 20, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(c, style: t.textTheme.bodyLarge)),
                    ]),
                  ),
                const SizedBox(height: 6),
                Text('Con los traseros activos el sonido "viene de atrás" y la medición se sesga.',
                    style: t.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ]),
            ),
            const SizedBox(height: 16),
            Text(
              widget.firstRun
                  ? 'Tendrás 10 s para dejar el teléfono; después sonarán sonidos de prueba durante algo más de un minuto. '
                      'Un tono ascendente al final es éxito; uno grave, que hay que repetir.'
                  : 'Al medir tendrás 10 s para dejar el teléfono. Un tono ascendente al final es éxito; '
                      'uno grave, que hay que repetir.',
              style: t.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (widget.firstRun) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _hide,
                onChanged: (v) => setState(() => _hide = v ?? false),
                title: const Text('No volver a mostrar'),
                subtitle: const Text('Siempre la encuentras con el icono de ayuda'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
                onPressed: () => Navigator.pop(context, (start: true, hide: _hide)),
                child: const Text('Entendido, empezar', style: TextStyle(fontSize: 18)),
              ),
            ] else
              FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.child, required this.caption});

  final Widget child;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(children: [
        AspectRatio(aspectRatio: 1.6, child: child),
        const SizedBox(height: 6),
        Text(caption,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

void _text(Canvas c, String s, Offset at, Color color,
    {double size = 12, TextAlign align = TextAlign.center, bool bold = false, double maxW = 140}) {
  final tp = TextPainter(
    text: TextSpan(
        text: s,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, height: 1.15)),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxW);
  final dx = align == TextAlign.center ? -tp.width / 2 : (align == TextAlign.right ? -tp.width : 0);
  tp.paint(c, at + Offset(dx.toDouble(), -tp.height / 2));
}

void _dashed(Canvas c, Offset a, Offset b, Paint p, {double dash = 6, double gap = 5}) {
  final len = (b - a).distance;
  final dir = (b - a) / len;
  for (var d = 0.0; d < len; d += dash + gap) {
    c.drawLine(a + dir * d, a + dir * (d + dash).clamp(0, len), p);
  }
}

void _arrow(Canvas c, Offset a, Offset b, Paint p) {
  c.drawLine(a, b, p);
  final dir = (b - a) / (b - a).distance;
  final n = Offset(-dir.dy, dir.dx);
  final path = Path()
    ..moveTo(b.dx, b.dy)
    ..lineTo((b - dir * 9 + n * 5).dx, (b - dir * 9 + n * 5).dy)
    ..lineTo((b - dir * 9 - n * 5).dx, (b - dir * 9 - n * 5).dy)
    ..close();
  c.drawPath(path, Paint()..color = p.color);
}

/// Teléfono (rectángulo) con el borde del micrófono marcado.
void _phoneTop(Canvas c, Rect r, Color body, Color screen) {
  c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), Paint()..color = body);
  c.drawRRect(RRect.fromRectAndRadius(r.deflate(2.5), const Radius.circular(3)), Paint()..color = screen);
}

/// Vista desde arriba: delante hacia arriba, conductor a la izquierda (volante a la izquierda).
class _TopViewPainter extends CustomPainter {
  _TopViewPainter(this.s, this.dark);

  final ColorScheme s;
  final bool dark;

  @override
  void paint(Canvas c, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..color = s.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..color = s.surfaceContainerHighest;

    // carroceria
    final body = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.14, h * 0.04, w * 0.86, h * 0.98), Radius.circular(w * 0.1));
    c.drawRRect(body, Paint()..color = s.surfaceContainer);
    c.drawRRect(body, line);
    // parabrisas
    final wind = Rect.fromLTRB(w * 0.2, h * 0.1, w * 0.8, h * 0.2);
    c.drawRRect(RRect.fromRectAndRadius(wind, const Radius.circular(8)),
        Paint()..color = s.tertiaryContainer.withValues(alpha: 0.7));
    _text(c, 'Parabrisas (frente)', wind.center, s.onTertiaryContainer, size: 11, maxW: w * 0.5);

    // asiento del conductor (izquierda)
    final seatC = Offset(w * 0.34, h * 0.64);
    final seat = RRect.fromRectAndRadius(
        Rect.fromCenter(center: seatC, width: w * 0.2, height: h * 0.4), const Radius.circular(12));
    c.drawRRect(seat, fill);
    c.drawRRect(seat, line..strokeWidth = 1.5);
    // asiento del copiloto
    final seat2 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.66, h * 0.64), width: w * 0.2, height: h * 0.4),
        const Radius.circular(12));
    c.drawRRect(seat2, fill);
    c.drawRRect(seat2, line);

    // altavoces izquierdo y derecho (puertas)
    for (final left in [true, false]) {
      final p = Offset(left ? w * 0.145 : w * 0.855, h * 0.45);
      c.drawCircle(p, 10, Paint()..color = s.secondary);
      _text(c, left ? 'I' : 'D', p, s.onSecondary, size: 12, bold: true);
    }

    // posicion de la cabeza: marcas de centro y distancias a las puertas
    final head = Offset(seatC.dx, h * 0.50);
    final guide = Paint()
      ..color = s.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _dashed(c, Offset(head.dx, h * 0.3), Offset(head.dx, h * 0.8), guide);
    // flechas hacia las puertas: igual distancia
    _arrow(c, Offset(head.dx - w * 0.08, head.dy + h * 0.17), Offset(w * 0.17, head.dy + h * 0.17), guide);
    _arrow(c, Offset(head.dx + w * 0.08, head.dy + h * 0.17), Offset(w * 0.5, head.dy + h * 0.17), guide);
    _text(c, 'Centrado', Offset(head.dx, h * 0.9), s.primary, size: 12, bold: true);

    // telefono: borde de abajo (microfono) hacia el frente (arriba)
    final ph = Rect.fromCenter(center: head, width: w * 0.075, height: h * 0.2);
    _phoneTop(c, ph, s.onSurface, dark ? const Color(0xFF263238) : const Color(0xFF455A64));
    // microfono: punto en el borde delantero (arriba) y flecha hacia el frente
    final mic = Offset(ph.center.dx, ph.top + 5);
    c.drawCircle(mic, 4, Paint()..color = s.error);
    _arrow(c, Offset(ph.center.dx, ph.top - 4), Offset(ph.center.dx, h * 0.25), Paint()..color = s.error..strokeWidth = 2.5);
    _text(c, 'Micrófono\nhacia el frente', Offset(w * 0.5, h * 0.355), s.error,
        size: 11, bold: true, maxW: w * 0.2);

    // puertas: aviso
    _text(c, 'No pegado\na la puerta', Offset(w * 0.075, h * 0.7), s.onSurfaceVariant,
        size: 10, maxW: w * 0.13);
  }

  @override
  bool shouldRepaint(_TopViewPainter old) => old.s != s || old.dark != dark;
}

/// Vista de lado: delante hacia la derecha.
class _SideViewPainter extends CustomPainter {
  _SideViewPainter(this.s, this.dark);

  final ColorScheme s;
  final bool dark;

  @override
  void paint(Canvas c, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..color = s.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..color = s.surfaceContainerHighest;

    // suelo y parabrisas
    c.drawLine(Offset(w * 0.04, h * 0.93), Offset(w * 0.96, h * 0.93), line);
    final windshield = Path()
      ..moveTo(w * 0.93, h * 0.82)
      ..lineTo(w * 0.8, h * 0.18);
    c.drawPath(windshield, line..strokeWidth = 4);
    line.strokeWidth = 2;
    _text(c, 'Parabrisas', Offset(w * 0.86, h * 0.1), s.onSurfaceVariant, size: 11, maxW: w * 0.2);

    // asiento: cojin y respaldo
    final cushion = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.12, h * 0.76, w * 0.46, h * 0.86), const Radius.circular(12));
    c.drawRRect(cushion, fill);
    c.drawRRect(cushion, line);
    c.save();
    c.translate(w * 0.17, h * 0.78);
    c.rotate(-0.12);
    final back = RRect.fromRectAndRadius(
        Rect.fromLTRB(-w * 0.05, -h * 0.46, w * 0.05, 0), const Radius.circular(12));
    c.drawRRect(back, fill);
    c.drawRRect(back, line);
    c.restore();
    // reposacabezas
    final headrest = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.095, h * 0.2, w * 0.195, h * 0.37), const Radius.circular(10));
    c.drawRRect(headrest, fill);
    c.drawRRect(headrest, line);

    // cabeza (referencia) y linea de la altura de los oidos
    final earY = h * 0.3;
    final headC = Offset(w * 0.34, earY - h * 0.02);
    c.drawCircle(headC, h * 0.14, Paint()..color = s.primary.withValues(alpha: 0.12));
    final guide = Paint()
      ..color = s.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _dashed(c, headC.translate(0, 0) + Offset(-h * 0.14, 0), Offset(w * 0.74, earY), guide);
    c.drawCircle(Offset(headC.dx, earY), 5, Paint()..color = s.primary);
    _text(c, 'Altura de los oídos', Offset(w * 0.58, earY - h * 0.07), s.primary, size: 12, bold: true, maxW: w * 0.3);

    // telefono tumbado sobre el reposacabezas (perfil): microfono delante
    final ph = Rect.fromLTRB(w * 0.14, earY - h * 0.045, w * 0.4, earY + h * 0.0);
    c.drawRRect(RRect.fromRectAndRadius(ph, const Radius.circular(4)), Paint()..color = s.onSurface);
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(ph.left + 3, ph.top + 1.5, ph.right - 3, ph.top + 5), const Radius.circular(2)),
        Paint()..color = dark ? const Color(0xFF263238) : const Color(0xFF455A64));
    c.drawCircle(Offset(ph.right - 4, ph.bottom - 3), 3.5, Paint()..color = s.error);
    final errP = Paint()
      ..color = s.error
      ..strokeWidth = 2.5;
    _arrow(c, Offset(ph.right + 6, ph.center.dy + 14), Offset(w * 0.74, ph.center.dy + 14), errP);
    _text(c, 'Micrófono (borde de abajo)\nhacia el frente', Offset(w * 0.56, ph.center.dy + 42), s.error,
        size: 11, bold: true, maxW: w * 0.36);
    _text(c, 'Teléfono\ntumbado', Offset(w * 0.27, ph.top - 22), s.onSurface, size: 11, bold: true, maxW: w * 0.2);
  }

  @override
  bool shouldRepaint(_SideViewPainter old) => old.s != s || old.dark != dark;
}
