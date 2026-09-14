import 'dart:math';
import 'package:flutter/material.dart';
import '../models/plate_data.dart';
import '../models/test_mode.dart';

class PlateGenerator {
  /// Generates battery for [mode] (Quick: 6, Standard: 14, Comprehensive: 24).
  /// Plate 1 (Demonstration) is always kept first, while subsequent plates are shuffled when [shuffle] is true.
  static List<PlateData> generateBattery({
    TestBatteryMode mode = TestBatteryMode.standard,
    int? seed,
    bool shuffle = true,
  }) {
    final s = seed ?? (DateTime.now().microsecondsSinceEpoch % 1000000);
    final allPlates = _buildAllPlates(s);

    List<PlateData> selected;
    switch (mode) {
      case TestBatteryMode.quick:
        // 6 Plates: Demo (1), Transformation (2, 3), Vanishing (4), Diagnostic (11), Tritan (14)
        selected = [
          allPlates[0], // Plate 1
          allPlates[1], // Plate 2
          allPlates[2], // Plate 3
          allPlates[3], // Plate 4
          allPlates[10], // Plate 11
          allPlates[13], // Plate 14
        ];
        break;
      case TestBatteryMode.standard:
        selected = allPlates.sublist(0, 14);
        break;
      case TestBatteryMode.comprehensive:
        selected = allPlates;
        break;
    }

    if (shuffle) {
      final demo = selected.first;
      final remaining = selected.sublist(1);
      final shuffleRand = Random(s);
      remaining.shuffle(shuffleRand);
      return [demo, ...remaining];
    }

    return selected;
  }

  /// Backwards-compatible adult battery generator (defaults to Standard 14-plate battery)
  static List<PlateData> generateAdultBattery({int? seed, bool shuffle = true}) {
    return generateBattery(mode: TestBatteryMode.standard, seed: seed, shuffle: shuffle);
  }

  static List<PlateData> _buildAllPlates(int s) {
    return [
      // 1. Demonstration plate: Visible to everyone
      _buildPlate(
        number: 1,
        type: PlateType.demonstration,
        deficiency: TargetDeficiency.none,
        digits: "12",
        normalAnswer: "12",
        cvdAnswer: "12",
        title: "Demonstration Plate",
        fgColors: [
          const Color(0xFFE65100),
          const Color(0xFFEF6C00),
          const Color(0xFFF4511E),
          const Color(0xFFFF7043),
        ],
        bgColors: [
          const Color(0xFF00838F),
          const Color(0xFF0097A7),
          const Color(0xFF00ACC1),
          const Color(0xFF006064),
        ],
        seed: s + 1,
      ),

      // 2. Transformation plate: Normal sees 8, Red-Green sees 3
      _buildPlate(
        number: 2,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "8",
        normalAnswer: "8",
        cvdAnswer: "3",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFE64A19),
          const Color(0xFFF4511E),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
          const Color(0xFF9CCC65),
        ],
        seed: s + 2,
      ),

      // 3. Transformation plate: Normal sees 29, Red-Green sees 70
      _buildPlate(
        number: 3,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "29",
        normalAnswer: "29",
        cvdAnswer: "70",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFE64A19),
          const Color(0xFFBF360C),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 3,
      ),

      // 4. Transformation plate: Normal sees 5, Red-Green sees 2
      _buildPlate(
        number: 4,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "5",
        normalAnswer: "5",
        cvdAnswer: "2",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFBF360C),
          const Color(0xFFD84315),
          const Color(0xFFF4511E),
        ],
        bgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
          const Color(0xFF9CCC65),
        ],
        seed: s + 4,
      ),

      // 5. Transformation plate: Normal sees 3, Red-Green sees 5
      _buildPlate(
        number: 5,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "3",
        normalAnswer: "3",
        cvdAnswer: "5",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFE64A19),
          const Color(0xFFF4511E),
          const Color(0xFFFF5722),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 5,
      ),

      // 6. Transformation plate: Normal sees 15, Red-Green sees 17
      _buildPlate(
        number: 6,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "15",
        normalAnswer: "15",
        cvdAnswer: "17",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFE64A19),
          const Color(0xFFF4511E),
          const Color(0xFFFF7043),
        ],
        bgColors: [
          const Color(0xFF558B2F),
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
        ],
        seed: s + 6,
      ),

      // 7. Transformation plate: Normal sees 74, Red-Green sees 21
      _buildPlate(
        number: 7,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "74",
        normalAnswer: "74",
        cvdAnswer: "21",
        title: "Transformation Plate",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFE64A19),
          const Color(0xFFBF360C),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 7,
      ),

      // 8. Vanishing plate: Normal sees 6, Red-Green sees nothing
      _buildPlate(
        number: 8,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "6",
        normalAnswer: "6",
        cvdAnswer: "nothing",
        title: "Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFBF360C),
          const Color(0xFFC2185B),
          const Color(0xFFD84315),
        ],
        bgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 8,
      ),

      // 9. Vanishing plate: Normal sees 45, Red-Green sees nothing
      _buildPlate(
        number: 9,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "45",
        normalAnswer: "45",
        cvdAnswer: "nothing",
        title: "Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFBF360C),
          const Color(0xFFD84315),
          const Color(0xFFC2185B),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF558B2F),
          const Color(0xFF7CB342),
        ],
        seed: s + 9,
      ),

      // 10. Vanishing plate: Normal sees 7, Red-Green sees nothing
      _buildPlate(
        number: 10,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "7",
        normalAnswer: "7",
        cvdAnswer: "nothing",
        title: "Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFE64A19),
          const Color(0xFFF4511E),
        ],
        bgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
          const Color(0xFF9CCC65),
        ],
        seed: s + 10,
      ),

      // 11. Diagnostic Plate: Normal sees 26, Protan sees 6, Deutan sees 2
      _buildPlate(
        number: 11,
        type: PlateType.diagnostic,
        deficiency: TargetDeficiency.protanVsDeutan,
        digits: "26",
        normalAnswer: "26",
        protanAnswer: "6",
        deutanAnswer: "2",
        cvdAnswer: "nothing",
        title: "Protan vs Deutan Diagnostic",
        fgColors: [
          const Color(0xFF880E4F), // Purple-red (Deutan sees this clearer)
          const Color(0xFFBF360C), // Orange-red (Protan sees this clearer)
        ],
        bgColors: [
          const Color(0xFF558B2F),
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
        ],
        seed: s + 11,
      ),

      // 12. Diagnostic Plate: Normal sees 42, Protan sees 2, Deutan sees 4
      _buildPlate(
        number: 12,
        type: PlateType.diagnostic,
        deficiency: TargetDeficiency.protanVsDeutan,
        digits: "42",
        normalAnswer: "42",
        protanAnswer: "2",
        deutanAnswer: "4",
        cvdAnswer: "nothing",
        title: "Protan vs Deutan Diagnostic",
        fgColors: [
          const Color(0xFFAD1457),
          const Color(0xFFD84315),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 12,
      ),

      // 13. Diagnostic Plate: Normal sees 35, Protan sees 5, Deutan sees 3
      _buildPlate(
        number: 13,
        type: PlateType.diagnostic,
        deficiency: TargetDeficiency.protanVsDeutan,
        digits: "35",
        normalAnswer: "35",
        protanAnswer: "5",
        deutanAnswer: "3",
        cvdAnswer: "nothing",
        title: "Protan vs Deutan Diagnostic",
        fgColors: [
          const Color(0xFF880E4F),
          const Color(0xFFE64A19),
        ],
        bgColors: [
          const Color(0xFF558B2F),
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
        ],
        seed: s + 13,
      ),

      // 14. Tritan Screening Plate: Violet-Teal confusion axis
      _buildPlate(
        number: 14,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.tritan,
        digits: "16",
        normalAnswer: "16",
        cvdAnswer: "nothing",
        title: "Tritan (Blue-Yellow) Screening",
        fgColors: [
          const Color(0xFF7E57C2), // Violet / Purple (collapses with teal under tritanopia)
          const Color(0xFF673AB7),
          const Color(0xFF5E35B1),
        ],
        bgColors: [
          const Color(0xFF26A69A), // Teal / Green
          const Color(0xFF00897B),
          const Color(0xFF00796B),
        ],
        seed: s + 14,
      ),

      // 15. Extended Transformation plate: Normal sees 73
      _buildPlate(
        number: 15,
        type: PlateType.transformation,
        deficiency: TargetDeficiency.redGreen,
        digits: "73",
        normalAnswer: "73",
        cvdAnswer: "nothing",
        title: "Extended Transformation Plate",
        fgColors: [
          const Color(0xFFE64A19),
          const Color(0xFFD84315),
          const Color(0xFFF4511E),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 15,
      ),

      // 16. Extended Vanishing plate: Normal sees 2
      _buildPlate(
        number: 16,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "2",
        normalAnswer: "2",
        cvdAnswer: "nothing",
        title: "Extended Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFBF360C),
        ],
        bgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
          const Color(0xFF9CCC65),
        ],
        seed: s + 16,
      ),

      // 17. Extended Vanishing plate: Normal sees 6
      _buildPlate(
        number: 17,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "6",
        normalAnswer: "6",
        cvdAnswer: "nothing",
        title: "Extended Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFBF360C),
          const Color(0xFFC2185B),
        ],
        bgColors: [
          const Color(0xFF558B2F),
          const Color(0xFF689F38),
        ],
        seed: s + 17,
      ),

      // 18. Extended Vanishing plate: Normal sees 97
      _buildPlate(
        number: 18,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "97",
        normalAnswer: "97",
        cvdAnswer: "nothing",
        title: "Extended Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFE64A19),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 18,
      ),

      // 19. Hidden Digit Plate: Normal sees nothing, Red-Green sees 5
      _buildPlate(
        number: 19,
        type: PlateType.hiddenDigit,
        deficiency: TargetDeficiency.redGreen,
        digits: "5",
        normalAnswer: "nothing",
        cvdAnswer: "5",
        title: "Hidden Digit Plate",
        fgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF558B2F),
          const Color(0xFF7CB342),
        ],
        seed: s + 19,
      ),

      // 20. Hidden Digit Plate: Normal sees nothing, Red-Green sees 2
      _buildPlate(
        number: 20,
        type: PlateType.hiddenDigit,
        deficiency: TargetDeficiency.redGreen,
        digits: "2",
        normalAnswer: "nothing",
        cvdAnswer: "2",
        title: "Hidden Digit Plate",
        fgColors: [
          const Color(0xFF8BC34A),
          const Color(0xFF9CCC65),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF558B2F),
        ],
        seed: s + 20,
      ),

      // 21. Extended Diagnostic Plate: Normal sees 96, Protan sees 6, Deutan sees 9
      _buildPlate(
        number: 21,
        type: PlateType.diagnostic,
        deficiency: TargetDeficiency.protanVsDeutan,
        digits: "96",
        normalAnswer: "96",
        protanAnswer: "6",
        deutanAnswer: "9",
        cvdAnswer: "nothing",
        title: "Extended Diagnostic Plate",
        fgColors: [
          const Color(0xFF880E4F),
          const Color(0xFFBF360C),
        ],
        bgColors: [
          const Color(0xFF558B2F),
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
        ],
        seed: s + 21,
      ),

      // 22. Extended Vanishing plate: Normal sees 15
      _buildPlate(
        number: 22,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "15",
        normalAnswer: "15",
        cvdAnswer: "nothing",
        title: "Extended Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFD84315),
          const Color(0xFFF4511E),
        ],
        bgColors: [
          const Color(0xFF7CB342),
          const Color(0xFF8BC34A),
        ],
        seed: s + 22,
      ),

      // 23. Extended Vanishing plate: Normal sees 74
      _buildPlate(
        number: 23,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.redGreen,
        digits: "74",
        normalAnswer: "74",
        cvdAnswer: "nothing",
        title: "Extended Vanishing Plate (Red-Green)",
        fgColors: [
          const Color(0xFFBF360C),
          const Color(0xFFD84315),
        ],
        bgColors: [
          const Color(0xFF689F38),
          const Color(0xFF7CB342),
        ],
        seed: s + 23,
      ),

      // 24. Extended Tritan Plate: Violet-Amber confusion axis
      _buildPlate(
        number: 24,
        type: PlateType.vanishing,
        deficiency: TargetDeficiency.tritan,
        digits: "7",
        normalAnswer: "7",
        cvdAnswer: "nothing",
        title: "Extended Tritan (Blue-Yellow) Plate",
        fgColors: [
          const Color(0xFF7E57C2),
          const Color(0xFF9575CD),
        ],
        bgColors: [
          const Color(0xFFFBC02D),
          const Color(0xFFFDD835),
        ],
        seed: s + 24,
      ),
    ];
  }

  /// Builds an individual plate with dot packing and glyph masking
  static PlateData _buildPlate({
    required int number,
    required PlateType type,
    required TargetDeficiency deficiency,
    required String digits,
    required String normalAnswer,
    String? cvdAnswer,
    String? protanAnswer,
    String? deutanAnswer,
    required String title,
    required List<Color> fgColors,
    required List<Color> bgColors,
    required int seed,
  }) {
    final rand = Random(seed);
    final List<PlateDot> dots = [];

    // Dot packing parameters
    const double plateRadius = 0.88;
    const int maxAttempts = 1800;
    const double minR = 0.022;
    const double maxR = 0.052;

    for (int i = 0; i < maxAttempts; i++) {
      // Sample polar coordinates with uniform area distribution
      final double rDist = sqrt(rand.nextDouble()) * (plateRadius - maxR);
      final double angle = rand.nextDouble() * 2 * pi;
      final double x = rDist * cos(angle);
      final double y = rDist * sin(angle);

      final double radius = minR + rand.nextDouble() * (maxR - minR);

      // Check collision with existing dots
      bool collides = false;
      for (final existing in dots) {
        final dx = x - existing.x;
        final dy = y - existing.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < (radius + existing.radius) * 0.94) {
          collides = true;
          break;
        }
      }

      if (collides) continue;

      // Determine if point (x, y) is inside the glyph mask
      final bool isFg = _isInsideDigits(x, y, digits);

      // Choose color
      Color color;
      if (isFg) {
        // Foreground color
        if (type == PlateType.diagnostic && digits.length >= 2) {
          // In diagnostic plates, digit 1 uses fgColors[0] and digit 2 uses fgColors[1]
          final isLeftDigit = x < 0.0;
          final colorPool = isLeftDigit ? [fgColors.first] : [fgColors.last];
          color = colorPool[rand.nextInt(colorPool.length)];
        } else {
          color = fgColors[rand.nextInt(fgColors.length)];
        }
      } else {
        color = bgColors[rand.nextInt(bgColors.length)];
      }

      // Add slight lightness jitter for natural biological texture
      final jitter = (rand.nextDouble() - 0.5) * 0.08;
      final hsl = HSLColor.fromColor(color);
      final adjustedColor = hsl
          .withLightness((hsl.lightness + jitter).clamp(0.1, 0.9))
          .toColor();

      dots.add(PlateDot(
        x: x,
        y: y,
        radius: radius,
        color: adjustedColor,
        isForeground: isFg,
      ));
    }

    return PlateData(
      plateNumber: number,
      plateType: type,
      targetDeficiency: deficiency,
      normalAnswer: normalAnswer,
      cvdAnswer: cvdAnswer,
      protanAnswer: protanAnswer,
      deutanAnswer: deutanAnswer,
      dots: dots,
      title: title,
    );
  }

  /// Determines if point (x, y) lies inside the glyph mask for [digits]
  static bool _isInsideDigits(double x, double y, String digits) {
    if (digits.length == 1) {
      return _isInsideDigit(x, y, digits[0]);
    } else if (digits.length == 2) {
      // 2-digit layout: offset left and right
      const double spacing = 0.28;
      const double scale = 0.82;

      final leftX = (x + spacing) / scale;
      final leftY = y / scale;
      if (_isInsideDigit(leftX, leftY, digits[0])) return true;

      final rightX = (x - spacing) / scale;
      final rightY = y / scale;
      if (_isInsideDigit(rightX, rightY, digits[1])) return true;

      return false;
    }
    return false;
  }

  /// Evaluates distance from (x, y) to standard geometric strokes of digit char
  static bool _isInsideDigit(double x, double y, String char) {
    const double strokeW = 0.125;

    // Stroke segments: list of lines ((x1, y1), (x2, y2)) or arc approximations
    final strokes = _digitStrokes[char];
    if (strokes == null) return false;

    for (final seg in strokes) {
      final d = _distToSegment(x, y, seg[0], seg[1], seg[2], seg[3]);
      if (d <= strokeW) {
        return true;
      }
    }
    return false;
  }

  /// Distance from point (px, py) to line segment (x1, y1)-(x2, y2)
  static double _distToSegment(
      double px, double py, double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthSq = dx * dx + dy * dy;

    if (lengthSq == 0) {
      final ex = px - x1;
      final ey = py - y1;
      return sqrt(ex * ex + ey * ey);
    }

    final t = max(0.0, min(1.0, ((px - x1) * dx + (py - y1) * dy) / lengthSq));
    final projX = x1 + t * dx;
    final projY = y1 + t * dy;

    final rx = px - projX;
    final ry = py - projY;
    return sqrt(rx * rx + ry * ry);
  }

  /// Vector stroke segments for digits 0..9 normalized in [-0.25, 0.25] x [-0.5, 0.5]
  static final Map<String, List<List<double>>> _digitStrokes = {
    '1': [
      [-0.10, -0.32, 0.04, -0.44],
      [0.04, -0.44, 0.04, 0.44],
      [-0.14, 0.44, 0.18, 0.44],
    ],
    '2': [
      [-0.18, -0.36, -0.06, -0.46],
      [-0.06, -0.46, 0.12, -0.46],
      [0.12, -0.46, 0.18, -0.34],
      [0.18, -0.34, 0.16, -0.16],
      [0.16, -0.16, -0.18, 0.42],
      [-0.18, 0.42, 0.20, 0.42],
    ],
    '3': [
      [-0.18, -0.44, 0.16, -0.44],
      [0.16, -0.44, 0.00, -0.05],
      [0.00, -0.05, 0.16, 0.08],
      [0.16, 0.08, 0.16, 0.32],
      [0.16, 0.32, 0.04, 0.44],
      [0.04, 0.44, -0.18, 0.44],
    ],
    '4': [
      [0.12, 0.44, 0.12, -0.44],
      [0.12, -0.44, -0.20, 0.10],
      [-0.20, 0.10, 0.22, 0.10],
    ],
    '5': [
      [0.18, -0.44, -0.16, -0.44],
      [-0.16, -0.44, -0.16, -0.06],
      [-0.16, -0.06, 0.14, -0.06],
      [0.14, -0.06, 0.18, 0.14],
      [0.18, 0.14, 0.12, 0.42],
      [0.12, 0.42, -0.18, 0.42],
    ],
    '6': [
      [0.12, -0.42, -0.16, -0.10],
      [-0.16, -0.10, -0.16, 0.34],
      [-0.16, 0.34, 0.00, 0.44],
      [0.00, 0.44, 0.16, 0.34],
      [0.16, 0.34, 0.16, 0.06],
      [0.16, 0.06, -0.16, 0.06],
    ],
    '7': [
      [-0.18, -0.44, 0.18, -0.44],
      [0.18, -0.44, -0.06, 0.44],
    ],
    '8': [
      // Top loop
      [-0.14, -0.24, 0.14, -0.24],
      [-0.14, -0.44, 0.14, -0.44],
      [-0.14, -0.44, -0.14, -0.24],
      [0.14, -0.44, 0.14, -0.24],
      // Bottom loop
      [-0.18, 0.44, 0.18, 0.44],
      [-0.18, -0.05, 0.18, -0.05],
      [-0.18, -0.05, -0.18, 0.44],
      [0.18, -0.05, 0.18, 0.44],
    ],
    '9': [
      [-0.16, -0.06, 0.16, -0.06],
      [-0.16, -0.44, 0.16, -0.44],
      [-0.16, -0.44, -0.16, -0.06],
      [0.16, -0.44, 0.16, 0.28],
      [0.16, 0.28, -0.10, 0.44],
    ],
    '0': [
      [-0.16, -0.32, -0.16, 0.32],
      [0.16, -0.32, 0.16, 0.32],
      [-0.16, -0.44, 0.16, -0.44],
      [-0.16, 0.44, 0.16, 0.44],
    ],
  };
}
