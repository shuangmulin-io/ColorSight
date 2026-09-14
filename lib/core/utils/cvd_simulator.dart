import 'dart:math';
import 'package:flutter/material.dart';

enum CvdType {
  normal,
  protanopia, // Red-blind
  deuteranopia, // Green-blind
  tritanopia, // Blue-blind
}

/// Brettel/Viénot-based Color Vision Deficiency simulator
class CvdSimulator {
  /// Simulates how a given [Color] appears to someone with [type]
  static Color simulate(Color color, CvdType type) {
    if (type == CvdType.normal) return color;

    // Linearize sRGB [0..1]
    double r = _gammaToLinear(color.red / 255.0);
    double g = _gammaToLinear(color.green / 255.0);
    double b = _gammaToLinear(color.blue / 255.0);

    // Convert sRGB to LMS space (Hunt-Pointer-Estevez matrix)
    double l = 0.31399022 * r + 0.63951294 * g + 0.04649755 * b;
    double m = 0.15537241 * r + 0.75789446 * g + 0.08670142 * b;
    double s = 0.01775239 * r + 0.10944209 * g + 0.87256922 * b;

    double simL = l;
    double simM = m;
    double simS = s;

    switch (type) {
      case CvdType.protanopia:
        // Protanopia projection: replace L with combination of M and S
        simL = 1.05118294 * m - 0.05116099 * s;
        break;
      case CvdType.deuteranopia:
        // Deuteranopia projection: replace M with combination of L and S
        simM = 0.9513092 * l + 0.04866992 * s;
        break;
      case CvdType.tritanopia:
        // Tritanopia projection: replace S with combination of L and M
        simS = -0.8699345 * l + 1.8699345 * m;
        break;
      case CvdType.normal:
        break;
    }

    // Convert back from LMS to linear RGB (inverse HPE matrix)
    double rSim = 5.47221206 * simL - 4.6419601 * simM + 0.16963708 * simS;
    double gSim = -1.1252419 * simL + 2.29317094 * simM - 0.1678952 * simS;
    double bSim = 0.02980165 * simL - 0.19318073 * simM + 1.16364789 * simS;

    // Clamp and convert to sRGB
    int rInt = (_linearToGamma(rSim.clamp(0.0, 1.0)) * 255.0).round().clamp(0, 255);
    int gInt = (_linearToGamma(gSim.clamp(0.0, 1.0)) * 255.0).round().clamp(0, 255);
    int bInt = (_linearToGamma(bSim.clamp(0.0, 1.0)) * 255.0).round().clamp(0, 255);

    return Color.fromARGB(color.alpha, rInt, gInt, bInt);
  }

  static double _gammaToLinear(double val) {
    return (val > 0.04045) ? pow((val + 0.055) / 1.055, 2.4).toDouble() : val / 12.92;
  }

  static double _linearToGamma(double val) {
    return (val > 0.0031308) ? (1.055 * pow(val, 1.0 / 2.4) - 0.055).toDouble() : 12.92 * val;
  }
}
