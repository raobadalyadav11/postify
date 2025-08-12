import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TemplateGenerator {
  static Future<Uint8List> generatePoliticalTemplate({
    required String title,
    required String subtitle,
    required Color primaryColor,
    required Color secondaryColor,
    int width = 1080,
    int height = 1920,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // Background gradient
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [primaryColor, primaryColor.withOpacity(0.7)],
    );

    final paint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.width - 80);
    titlePainter.paint(canvas, Offset(40, size.height * 0.3));

    // Subtitle
    final subtitlePainter = TextPainter(
      text: TextSpan(
        text: subtitle,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subtitlePainter.layout(maxWidth: size.width - 80);
    subtitlePainter.paint(canvas, Offset(40, size.height * 0.4));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> generateFestivalTemplate({
    required String greeting,
    required String message,
    required Color festivalColor,
    int width = 1080,
    int height = 1080,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // Background
    final paint = Paint()..color = festivalColor.withOpacity(0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Decorative border
    final borderPaint = Paint()
      ..color = festivalColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
        const Radius.circular(20),
      ),
      borderPaint,
    );

    // Greeting
    final greetingPainter = TextPainter(
      text: TextSpan(
        text: greeting,
        style: TextStyle(
          color: festivalColor,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    greetingPainter.layout(maxWidth: size.width - 80);
    greetingPainter.paint(
      canvas,
      Offset((size.width - greetingPainter.width) / 2, size.height * 0.3),
    );

    // Message
    final messagePainter = TextPainter(
      text: TextSpan(
        text: message,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    messagePainter.layout(maxWidth: size.width - 80);
    messagePainter.paint(
      canvas,
      Offset((size.width - messagePainter.width) / 2, size.height * 0.5),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> generateSocialMediaTemplate({
    required String title,
    required String description,
    required Color backgroundColor,
    required Color textColor,
    int width = 1080,
    int height = 1080,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // Background
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: textColor,
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: size.width - 60);
    titlePainter.paint(
      canvas,
      Offset((size.width - titlePainter.width) / 2, size.height * 0.35),
    );

    // Description
    final descPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: TextStyle(
          color: textColor.withOpacity(0.8),
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descPainter.layout(maxWidth: size.width - 60);
    descPainter.paint(
      canvas,
      Offset((size.width - descPainter.width) / 2, size.height * 0.55),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
