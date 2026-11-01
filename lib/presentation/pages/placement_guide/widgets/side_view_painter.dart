import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';
import 'figure_drawing.dart';

/// Side view: front is to the right.
class SideViewPainter extends CustomPainter {
  SideViewPainter(this.s, this.dark);

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

    // floor and windshield
    c.drawLine(Offset(w * 0.04, h * 0.93), Offset(w * 0.96, h * 0.93), line);
    final windshield = Path()
      ..moveTo(w * 0.93, h * 0.82)
      ..lineTo(w * 0.8, h * 0.18);
    c.drawPath(windshield, line..strokeWidth = 4);
    line.strokeWidth = 2;
    drawLabel(c, t.placement.figure.windshield, Offset(w * 0.86, h * 0.1), s.onSurfaceVariant, size: 11, maxW: w * 0.2);

    // seat: cushion and backrest
    final cushion = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.12, h * 0.76, w * 0.46, h * 0.86),
      const Radius.circular(12),
    );
    c.drawRRect(cushion, fill);
    c.drawRRect(cushion, line);
    c.save();
    c.translate(w * 0.17, h * 0.78);
    c.rotate(-0.12);
    final back = RRect.fromRectAndRadius(Rect.fromLTRB(-w * 0.05, -h * 0.46, w * 0.05, 0), const Radius.circular(12));
    c.drawRRect(back, fill);
    c.drawRRect(back, line);
    c.restore();
    // headrest
    final headrest = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.095, h * 0.2, w * 0.195, h * 0.37),
      const Radius.circular(10),
    );
    c.drawRRect(headrest, fill);
    c.drawRRect(headrest, line);

    // head (reference) and the ear-height line
    final earY = h * 0.3;
    final headC = Offset(w * 0.34, earY - h * 0.02);
    c.drawCircle(headC, h * 0.14, Paint()..color = s.primary.withValues(alpha: 0.12));
    final guide = Paint()
      ..color = s.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    drawDashedLine(c, headC.translate(0, 0) + Offset(-h * 0.14, 0), Offset(w * 0.74, earY), guide);
    c.drawCircle(Offset(headC.dx, earY), 5, Paint()..color = s.primary);
    drawLabel(
      c,
      t.placement.figure.earHeight,
      Offset(w * 0.58, earY - h * 0.07),
      s.primary,
      size: 12,
      bold: true,
      maxW: w * 0.3,
    );

    // phone lying on the headrest (profile): microphone at the front
    final ph = Rect.fromLTRB(w * 0.14, earY - h * 0.045, w * 0.4, earY + h * 0.0);
    c.drawRRect(RRect.fromRectAndRadius(ph, const Radius.circular(4)), Paint()..color = s.onSurface);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(ph.left + 3, ph.top + 1.5, ph.right - 3, ph.top + 5),
        const Radius.circular(2),
      ),
      Paint()..color = dark ? const Color(0xFF263238) : const Color(0xFF455A64),
    );
    c.drawCircle(Offset(ph.right - 4, ph.bottom - 3), 3.5, Paint()..color = s.error);
    final errP = Paint()
      ..color = s.error
      ..strokeWidth = 2.5;
    drawArrow(c, Offset(ph.right + 6, ph.center.dy + 14), Offset(w * 0.74, ph.center.dy + 14), errP);
    drawLabel(
      c,
      t.placement.figure.micBottomEdge,
      Offset(w * 0.56, ph.center.dy + 42),
      s.error,
      size: 11,
      bold: true,
      maxW: w * 0.36,
    );
    drawLabel(
      c,
      t.placement.figure.phoneLying,
      Offset(w * 0.27, ph.top - 22),
      s.onSurface,
      size: 11,
      bold: true,
      maxW: w * 0.2,
    );
  }

  @override
  bool shouldRepaint(SideViewPainter old) => old.s != s || old.dark != dark;
}
