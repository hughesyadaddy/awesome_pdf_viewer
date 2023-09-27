import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A custom track shape for the Flutter Slider widget.
///
/// This shape extends [RoundedRectSliderTrackShape] and overrides the default behavior
/// to modify the size and positioning of the slider's track, especially in scenarios where
/// the thumb might be larger than usual.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    // Manually overriding the thumbWidth to ensure that when the thumb expands, the track does not shrink.
    const thumbWidth = 50;

    // Getting the width of the overlay for the slider, which appears around the thumb when it's pressed.
    final overlayWidth =
        sliderTheme.overlayShape!.getPreferredSize(isEnabled, isDiscrete).width;

    // Height of the slider track.
    final trackHeight = sliderTheme.trackHeight!;

    // Calculating the left and right positions of the track based on the thumb and overlay width.
    final trackLeft = offset.dx + math.max(overlayWidth / 2, thumbWidth / 2);
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackRight =
        trackLeft + parentBox.size.width - math.max(thumbWidth, overlayWidth);
    final trackBottom = trackTop + trackHeight;

    // If the width of the parentBox is less than the width of the slider (due to a large thumb or overlay),
    // the trackRight can end up being less than trackLeft. To handle this, we swap their positions.
    return Rect.fromLTRB(
      math.min(trackLeft, trackRight),
      trackTop,
      math.max(trackLeft, trackRight),
      trackBottom,
    );
  }
}
