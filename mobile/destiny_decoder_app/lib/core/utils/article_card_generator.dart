import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Generates beautiful share card images for Articles
class ArticleCardGenerator {
  static Future<Uint8List?> generateArticleCard({
    required String title,
    required String category,
    required int readTime,
    required Color categoryColor,
  }) async {
    const width = 1080.0;
    const height = 1920.0;
    const badgeHeight = 60.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Background gradient
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(width, height),
        [
          categoryColor.withValues(alpha: 0.4),
          categoryColor.withValues(alpha: 0.1),
        ],
      );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      paint,
    );

    // Dark overlay
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );
    
    final categoryText = category
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    final categoryPainter = TextPainter(
      text: TextSpan(
        text: categoryText.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    categoryPainter.layout();

    // Draw badge background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (width - categoryPainter.width - 40) / 2,
          200,
          categoryPainter.width + 40,
          badgeHeight,
        ),
        const Radius.circular(30),
      ),
      Paint()..color = categoryColor.withValues(alpha: 0.8),
    );

    // Draw category text
    categoryPainter.paint(
      canvas,
      Offset(
        (width - categoryPainter.width) / 2,
        220,
      ),
    );

    // Title (centered, large, wrapped)
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: width - 80);
    titlePainter.paint(
      canvas,
      Offset(
        (width - titlePainter.width) / 2,
        500,
      ),
    );

    // Read time badge
    final readTimePainter = TextPainter(
      text: TextSpan(
        text: '$readTime min read',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 28,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    readTimePainter.layout();
    readTimePainter.paint(
      canvas,
      Offset(
        (width - readTimePainter.width) / 2,
        1200,
      ),
    );

    // Decorative line
    canvas.drawLine(
      const Offset(150, 1350),
      const Offset(width - 150, 1350),
      Paint()
        ..color = Colors.white30
        ..strokeWidth = 2,
    );

    // Footer text
    const footerText = 'Explore numerology insights\nwith Destiny Decoder';
    final footerPainter = TextPainter(
      text: const TextSpan(
        text: footerText,
        style: TextStyle(
          color: Colors.white60,
          fontSize: 26,
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
        1550,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
