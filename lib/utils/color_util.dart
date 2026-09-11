import 'package:flutter/material.dart';

class ColorUtils {
  static Color applyOpacity(Color color, double opacity) {
    final alpha = (opacity.clamp(0.0, 1.0) * 255).round();
    return color.withAlpha(alpha);
  }
}
