import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import 'figure_drawing.dart';

/// Top view: front is up, the driver sits on the left (left-hand drive).
class TopViewPainter extends CustomPainter {
  TopViewPainter(this.s, this.dark);

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

    // car body
    final body = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.14, h * 0.04, w * 0.86, h * 0.98), Radius.circular(w * 0.1));
    c.drawRRect(body, Paint()..color = s.surfaceContainer);
    c.drawRRect(body, line);
    // windshield
    final wind = Rect.fromLTRB(w * 0.2, h * 0.1, w * 0.8, h * 0.2);
    c.drawRRect(RRect.fromRectAndRadius(wind, const Radius.circular(8)),
        Paint()..color = s.tertiaryContainer.withValues(alpha: 0.7));
    drawLabel(c, t.placement.figure.windshieldFront, wind.center, s.onTertiaryContainer, size: 11, maxW: w * 0.5);

    // driver's seat (left)
    final seatC = Offset(w * 0.34, h * 0.64);
    final seat = RRect.fromRectAndRadius(
        Rect.fromCenter(center: seatC, width: w * 0.2, height: h * 0.4), const Radius.circular(12));
    c.drawRRect(seat, fill);
    c.drawRRect(seat, line..strokeWidth = 1.5);
    // passenger's seat
    final seat2 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.66, h * 0.64), width: w * 0.2, height: h * 0.4),
        const Radius.circular(12));
    c.drawRRect(seat2, fill);
    c.drawRRect(seat2, line);

    // left and right speakers (doors)
    for (final left in [true, false]) {
      final p = Offset(left ? w * 0.145 : w * 0.855, h * 0.45);
      c.drawCircle(p, 10, Paint()..color = s.secondary);
      drawLabel(c, left ? t.placement.figure.leftMarker : t.placement.figure.rightMarker, p, s.onSecondary, size: 12, bold: true);
    }

    // head position: center mark and distances to the doors
    final head = Offset(seatC.dx, h * 0.50);
    final guide = Paint()
      ..color = s.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    drawDashedLine(c, Offset(head.dx, h * 0.3), Offset(head.dx, h * 0.8), guide);
    // arrows toward the doors: equal distance
    drawArrow(c, Offset(head.dx - w * 0.08, head.dy + h * 0.17), Offset(w * 0.17, head.dy + h * 0.17), guide);
    drawArrow(c, Offset(head.dx + w * 0.08, head.dy + h * 0.17), Offset(w * 0.5, head.dy + h * 0.17), guide);
    drawLabel(c, t.placement.figure.centered, Offset(head.dx, h * 0.9), s.primary, size: 12, bold: true);

    // phone: bottom edge (microphone) toward the front (up)
    final ph = Rect.fromCenter(center: head, width: w * 0.075, height: h * 0.2);
    drawPhoneTop(c, ph, s.onSurface, dark ? const Color(0xFF263238) : const Color(0xFF455A64));
    // microphone: dot on the front edge (top) and an arrow toward the front
    final mic = Offset(ph.center.dx, ph.top + 5);
    c.drawCircle(mic, 4, Paint()..color = s.error);
    drawArrow(c, Offset(ph.center.dx, ph.top - 4), Offset(ph.center.dx, h * 0.25), Paint()..color = s.error..strokeWidth = 2.5);
    drawLabel(c, t.placement.figure.micForward, Offset(w * 0.5, h * 0.355), s.error,
        size: 11, bold: true, maxW: w * 0.2);

    // doors: warning
    drawLabel(c, t.placement.figure.notAgainstDoor, Offset(w * 0.075, h * 0.7), s.onSurfaceVariant,
        size: 10, maxW: w * 0.13);
  }

  @override
  bool shouldRepaint(TopViewPainter old) => old.s != s || old.dark != dark;
}
