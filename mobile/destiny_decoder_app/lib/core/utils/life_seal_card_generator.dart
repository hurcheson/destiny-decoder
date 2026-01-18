import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Generates beautiful share card images for Life Seals
class LifeSealCardGenerator {
  static Future<Uint8List?> generateLifeSealCard({
    required int lifeSealNumber,
    required String lifeSealName,
    required String planet,
    required Color accentColor,
  }) async {
    const width = 1080.0;
    const height = 1920.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Background with gradient
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(0, height),
        [
          accentColor.withValues(alpha: 0.3),
          accentColor.withValues(alpha: 0.05),
        ],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      paint,
    );

    // Dark overlay for text readability
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );

    // Title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'Your Life Seal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      const Offset(
        280,
        300,
      ),
    );

    // Large number with circle background
    const numberSize = 280.0;
    canvas.drawCircle(
      const Offset(540, 750),
      numberSize / 2,
      Paint()..color = accentColor,
    );

    final numberPainter = TextPainter(
      text: TextSpan(
        text: '$lifeSealNumber',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 200,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    numberPainter.layout();
    numberPainter.paint(
      canvas,
      Offset(
        (width - numberPainter.width) / 2,
        650,
      ),
    );

    // Life Seal name
    final namePainter = TextPainter(
      text: TextSpan(
        text: lifeSealName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(
      canvas,
      Offset(
        (width - namePainter.width) / 2,
        1100,
      ),
    );

    // Planet
    final planetPainter = TextPainter(
      text: TextSpan(
        text: '🪐 $planet',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 32,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    planetPainter.layout();
    planetPainter.paint(
      canvas,
      Offset(
        (width - planetPainter.width) / 2,
        1180,
      ),
    );

    // Footer
    final footerPainter = TextPainter(
      text: const TextSpan(
        text: 'Discover your destiny with\nDestiny Decoder 🔮',
        style: TextStyle(
          color: Colors.white60,
          fontSize: 24,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    footerPainter.layout(maxWidth: width - 100);
    footerPainter.paint(
      canvas,
      Offset(
        (width - footerPainter.width) / 2,
        1600,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
