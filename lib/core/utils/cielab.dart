import 'dart:math';
import 'package:flutter/material.dart';

/// Perceptual color utility based on CIE L*a*b* (D65 standard illuminant).
class CieLab {
  final double l;
  final double a;
  final double b;

  const CieLab(this.l, this.a, this.b);

  /// Convert standard Flutter [Color] to [CieLab]
  factory CieLab.fromColor(Color color) {
    return CieLab.fromRgb(color.red, color.green, color.blue);
  }

  /// Convert 8-bit sRGB to CIELAB
  factory CieLab.fromRgb(int r, int g, int b) {
    // 1. Convert sRGB to linear RGB
    double rLinear = _pivotRgb(r / 255.0);
    double gLinear = _pivotRgb(g / 255.0);
    double bLinear = _pivotRgb(b / 255.0);

    // 2. Convert linear RGB to CIE XYZ (D65 illuminant matrix)
    double x = (rLinear * 0.4124564 + gLinear * 0.3575761 + bLinear * 0.1804375) / 0.95047;
    double y = (rLinear * 0.2126729 + gLinear * 0.7151522 + bLinear * 0.0721750) / 1.00000;
    double z = (rLinear * 0.0193339 + gLinear * 0.1191920 + bLinear * 0.9503041) / 1.08883;

    // 3. Convert XYZ to CIELAB
    double fx = _pivotXyz(x);
    double fy = _pivotXyz(y);
    double fz = _pivotXyz(z);

    double lVal = max(0.0, (116.0 * fy) - 16.0);
    double aVal = 500.0 * (fx - fy);
    double bVal = 200.0 * (fy - fz);

    return CieLab(lVal, aVal, bVal);
  }

  static double _pivotRgb(double n) {
    return (n > 0.04045) ? pow((n + 0.055) / 1.055, 2.4).toDouble() : n / 12.92;
  }

  static double _pivotXyz(double n) {
    return (n > 0.008856) ? pow(n, 1.0 / 3.0).toDouble() : (7.787 * n) + (16.0 / 116.0);
  }

  /// Calculates the Euclidean perceptual color difference (CIE76 Delta E).
  /// Values < 2.0 are barely perceptible; > 10.0 are very distinct.
  double deltaE(CieLab other) {
    final dL = l - other.l;
    final da = a - other.a;
    final db = b - other.b;
    return sqrt(dL * dL + da * da + db * db);
  }
}
