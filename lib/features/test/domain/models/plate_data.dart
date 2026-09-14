import 'package:flutter/material.dart';

enum PlateType {
  demonstration, // Visible to everyone (calibration / sanity check)
  transformation, // Normal vision sees A, red-green deficient sees B
  vanishing, // Normal vision sees number, CVD sees nothing
  hiddenDigit, // Normal vision sees nothing/vague, CVD may see digit
  diagnostic, // Differentiates Protan (red) vs Deutan (green)
}

enum TargetDeficiency {
  none,
  redGreen,
  protanVsDeutan,
  tritan,
}

class PlateDot {
  final double x; // Normalized -1.0 to 1.0 from center
  final double y; // Normalized -1.0 to 1.0 from center
  final double radius; // Normalized radius (e.g. 0.02 to 0.06)
  final Color color;
  final bool isForeground;

  const PlateDot({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.isForeground,
  });
}

class PlateData {
  final int plateNumber;
  final PlateType plateType;
  final TargetDeficiency targetDeficiency;
  final String normalAnswer;
  final String? cvdAnswer;
  final String? protanAnswer;
  final String? deutanAnswer;
  final List<PlateDot> dots;
  final String title;

  const PlateData({
    required this.plateNumber,
    required this.plateType,
    required this.targetDeficiency,
    required this.normalAnswer,
    this.cvdAnswer,
    this.protanAnswer,
    this.deutanAnswer,
    required this.dots,
    required this.title,
  });
}
