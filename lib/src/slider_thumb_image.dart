import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A custom thumb shape for the Flutter Slider widget that uses an image as its appearance.
///
/// When provided with an image, this thumb shape will display the image inside its boundaries.
/// If no image is provided, a Cupertino-like spinner is displayed instead.
class SliderThumbImage extends SliderComponentShape {
  /// Constructs the [SliderThumbImage].
  ///
  /// - [image] is the ui.Image to be displayed as the thumb shape.
  ///   If null, a Cupertino-like spinner will be drawn instead.
  /// - [isDragging] is a boolean flag that is true if the slider thumb is being dragged by the user.
  /// - [rotation] is a double value representing the rotation angle for the Cupertino spinner (in radians).
  SliderThumbImage({
    this.image,
    this.isDragging = false,
    this.rotation = 0.0,
  });

  final ui.Image? image;
  final bool isDragging;
  final double rotation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final scale = isDragging ? 3.0 : 1.0;
    return Size(30 * scale, 50 * scale);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final scale = isDragging ? 1.5 : 1.1;

    // Draws a blue border around the thumb shape.
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(
          center.dx - (15 * scale) - 1,
          center.dy - (25 * scale) - 1,
        ),
        Offset(
          center.dx + (15 * scale) + 1,
          center.dy + (25 * scale) + 1,
        ),
      ),
      borderPaint,
    );

    // Draws a white background for the thumb shape.
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromPoints(
        Offset(center.dx - 15 * scale, center.dy - 25 * scale),
        Offset(center.dx + 15 * scale, center.dy + 25 * scale),
      ),
      paint,
    );

    if (image == null) {
      // Draws a Cupertino-like spinner in absence of an image.
      final spinnerPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (var i = 0; i < 12; i++) {
        canvas
          ..save()
          ..translate(center.dx, center.dy)
          ..rotate(2 * rotation + (math.pi / 6 * i));
        spinnerPaint.color = Colors.blue.withOpacity(1 - i / 12);
        canvas
          ..drawLine(const Offset(0, -8), const Offset(0, -15), spinnerPaint)
          ..restore();
      }
    } else {
      // Draws the thumb image.
      paintImage(
        canvas: canvas,
        rect: Rect.fromPoints(
          Offset(center.dx - 15 * scale, center.dy - 25 * scale),
          Offset(center.dx + 15 * scale, center.dy + 25 * scale),
        ),
        image: image!,
        fit: BoxFit.cover,
      );
    }
  }
}
