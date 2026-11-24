// Generates favicon, PWA icons and the Open Graph image from code.
//
//   flutter test tool/brand_assets_test.dart
//
// Text in the OG image uses a system font (macOS Arial) because Google Fonts
// aren't available offline in tests.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _bg = Color(0xFF080812);
const _primary = Color(0xFF9354CB);
const _secondary = Color(0xFF7547F5);
const _highlight = Color(0xFFA78BFA);

/// Geometric "MF" monogram on a gradient rounded square.
void _paintMonogram(Canvas canvas, double size, {double padding = 0, bool rounded = true}) {
  final rect = Rect.fromLTWH(padding, padding, size - padding * 2, size - padding * 2);
  final paint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_primary, _secondary],
    ).createShader(rect);
  if (rounded) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.28)), paint);
  } else {
    canvas.drawRect(rect, paint);
  }

  final s = rect.width;
  final o = rect.topLeft;
  Offset p(double x, double y) => o + Offset(x * s, y * s);
  final stroke = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.085
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // M
  canvas.drawPath(
    Path()
      ..moveTo(p(0.2, 0.7).dx, p(0.2, 0.7).dy)
      ..lineTo(p(0.2, 0.3).dx, p(0.2, 0.3).dy)
      ..lineTo(p(0.35, 0.5).dx, p(0.35, 0.5).dy)
      ..lineTo(p(0.5, 0.3).dx, p(0.5, 0.3).dy)
      ..lineTo(p(0.5, 0.7).dx, p(0.5, 0.7).dy),
    stroke,
  );
  // F
  canvas.drawPath(
    Path()
      ..moveTo(p(0.64, 0.7).dx, p(0.64, 0.7).dy)
      ..lineTo(p(0.64, 0.3).dx, p(0.64, 0.3).dy)
      ..lineTo(p(0.82, 0.3).dx, p(0.82, 0.3).dy)
      ..moveTo(p(0.64, 0.5).dx, p(0.64, 0.5).dy)
      ..lineTo(p(0.78, 0.5).dx, p(0.78, 0.5).dy),
    stroke,
  );
}

Future<void> _save(String path, int w, int h, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));
  paint(canvas);
  final image = await recorder.endRecording().toImage(w, h);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _text(Canvas canvas, String text, Offset at, double size, Color color,
    {FontWeight weight = FontWeight.w700, double spacing = 0}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontFamily: 'Brand', fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, at);
}

void main() {
  test('generate brand assets', () async {
    final loader = FontLoader('Brand')
      ..addFont(Future.value(ByteData.sublistView(
          File('/System/Library/Fonts/Supplemental/Arial Bold.ttf').readAsBytesSync())));
    await loader.load();

    // Favicon + PWA icons.
    await _save('web/favicon.png', 64, 64, (c) => _paintMonogram(c, 64, padding: 2));
    for (final size in [192, 512]) {
      await _save('web/icons/Icon-$size.png', size, size, (c) => _paintMonogram(c, size.toDouble()));
      // Maskable: full-bleed background, monogram inside the safe zone.
      await _save('web/icons/Icon-maskable-$size.png', size, size, (c) {
        c.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), Paint()..color = _bg);
        _paintMonogram(c, size.toDouble(), padding: size * 0.18);
      });
    }

    // Open Graph image (1200 × 630).
    await _save('web/og-image.png', 1200, 630, (c) {
      c.drawRect(const Rect.fromLTWH(0, 0, 1200, 630), Paint()..color = _bg);
      for (final (center, color, r) in [
        (const Offset(980, 120), _primary, 520.0),
        (const Offset(160, 620), _secondary, 420.0),
      ]) {
        c.drawCircle(
          center,
          r,
          Paint()
            ..shader = RadialGradient(colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)])
                .createShader(Rect.fromCircle(center: center, radius: r)),
        );
      }
      // Dot grid.
      final dot = Paint()..color = _highlight.withValues(alpha: 0.12);
      for (var x = 20.0; x < 1200; x += 40) {
        for (var y = 20.0; y < 630; y += 40) {
          c.drawCircle(Offset(x, y), 1.2, dot);
        }
      }
      c.save();
      c.translate(90, 96);
      _paintMonogram(c, 96);
      c.restore();
      _text(c, '// FLUTTER DEVELOPER PORTFOLIO', const Offset(90, 240), 22, _highlight, spacing: 3);
      _text(c, 'Muhammed Faisal V', const Offset(86, 280), 84, Colors.white);
      _text(c, 'Building beautiful digital experiences with Flutter.', const Offset(90, 392), 30,
          const Color(0xFFA1A1B5), weight: FontWeight.w400);
      var x = 90.0;
      for (final tag in ['Flutter & Dart', 'Firebase', 'Agora', 'Clean Architecture']) {
        final tp = TextPainter(
          text: TextSpan(text: tag, style: const TextStyle(fontFamily: 'Brand', fontSize: 22, color: Colors.white)),
          textDirection: TextDirection.ltr,
        )..layout();
        final rect = RRect.fromLTRBR(x, 470, x + tp.width + 40, 520, const Radius.circular(25));
        c.drawRRect(rect, Paint()..color = _primary.withValues(alpha: 0.16));
        c.drawRRect(rect, Paint()
          ..color = _highlight.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke);
        tp.paint(c, Offset(x + 20, 482));
        x += tp.width + 56;
      }
    });
  });
}
