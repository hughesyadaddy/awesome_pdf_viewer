import 'package:flutter/material.dart';

/// A custom shape for the value indicator of a `Slider`.
///
/// The indicator appears as a rectangular box with slightly rounded corners
/// that contains the current value of the slider.
///
/// You can adjust the vertical offset of the indicator relative to the
/// slider's thumb by using the `verticalOffset` parameter.
class CustomValueIndicatorShape extends SliderComponentShape {
  /// Creates a [CustomValueIndicatorShape].
  ///
  /// The [verticalOffset] parameter allows you to adjust the vertical position
  /// of the value indicator relative to the slider's thumb.
  /// The default value is `55.0`.
  CustomValueIndicatorShape({this.verticalOffset = 55.0});

  /// The vertical offset for the value indicator.
  ///
  /// Positive values will move the indicator upwards.
  final double verticalOffset;

  /// Provides the preferred size for the value indicator.
  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    TextPainter? labelPainter,
    double? textScaleFactor,
  }) {
    assert(labelPainter != null);
    return const Size(48, 48); // adjust these values if needed
  }

  /// Paints the value indicator.
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

    final adjustedCenter = Offset(center.dx, center.dy - verticalOffset);

    final paint = Paint()
      ..color = sliderTheme.valueIndicatorColor!
      ..style = PaintingStyle.fill;

    // Drawing the rectangular shape with slightly rounded corners.
    final rect = Rect.fromCenter(
      center: adjustedCenter,
      width: 30, // width of the rectangle
      height: 24, // height of the rectangle
    );
    const radius = Radius.circular(2);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Drawing the value inside
    labelPainter.layout();
    final labelX = adjustedCenter.dx - (labelPainter.width / 2);
    final labelY = adjustedCenter.dy - (labelPainter.height / 2);
    labelPainter.paint(canvas, Offset(labelX, labelY));
  }
}
