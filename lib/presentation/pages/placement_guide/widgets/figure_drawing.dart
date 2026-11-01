import 'package:flutter/material.dart';

/// Drawing helpers shared by the placement figures.
void drawLabel(Canvas c, String s, Offset at, Color color,
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

void drawDashedLine(Canvas c, Offset a, Offset b, Paint p, {double dash = 6, double gap = 5}) {
  final len = (b - a).distance;
  final dir = (b - a) / len;
  for (var d = 0.0; d < len; d += dash + gap) {
    c.drawLine(a + dir * d, a + dir * (d + dash).clamp(0, len), p);
  }
}

void drawArrow(Canvas c, Offset a, Offset b, Paint p) {
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

/// Phone (rectangle) seen from above.
void drawPhoneTop(Canvas c, Rect r, Color body, Color screen) {
  c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), Paint()..color = body);
  c.drawRRect(RRect.fromRectAndRadius(r.deflate(2.5), const Radius.circular(3)), Paint()..color = screen);
}
