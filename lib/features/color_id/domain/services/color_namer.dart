import 'package:flutter/material.dart';
import '../../../../core/utils/cielab.dart';
import '../../../../core/utils/cvd_simulator.dart';
import '../models/named_color.dart';

class ColorNamer {
  /// Matches a sampled [Color] to its basic and extended name, with luminance and confusion warnings
  static ColorMatchResult identify(Color color, {CvdType userCvdType = CvdType.normal}) {
    final sampleLab = CieLab.fromColor(color);

    // 1. Find best basic name (11 standard colors with multi-anchor coverage)
    String bestBasicName = 'Gray';
    double minBasicDist = double.infinity;

    for (final entry in _basicColorAnchors.entries) {
      for (final anchor in entry.value) {
        final refLab = CieLab.fromColor(anchor);
        final dist = sampleLab.deltaE(refLab);
        if (dist < minBasicDist) {
          minBasicDist = dist;
          bestBasicName = entry.key;
        }
      }
    }

    // 2. Find best extended name
    NamedColor bestExtended = _extendedColors.first;
    double minExtendedDist = double.infinity;

    for (final entry in _extendedColors) {
      final refLab = CieLab.fromColor(entry.referenceColor);
      final dist = sampleLab.deltaE(refLab);
      if (dist < minExtendedDist) {
        minExtendedDist = dist;
        bestExtended = entry;
      }
    }

    // 3. Luminance check
    final double luminance = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue) / 255.0;
    bool isPoorLighting = false;
    String? lightingWarning;

    if (luminance < 0.12) {
      isPoorLighting = true;
      lightingWarning = "Lighting is very dim — color accuracy may be reduced. Try more light if uncertain.";
    } else if (luminance > 0.92) {
      isPoorLighting = true;
      lightingWarning = "High glare or blown-out highlight detected — reading may be washed out.";
    }

    // 4. Personalized confusion warning
    String? confusionWarning;
    final basicLower = bestBasicName.toLowerCase();

    if (userCvdType == CvdType.deuteranopia || userCvdType == CvdType.protanopia) {
      if (basicLower == 'red') {
        confusionWarning = 'Notice: This is actually Red. It may look green, olive, or brown to you.';
      } else if (basicLower == 'green') {
        confusionWarning = 'Notice: This is actually Green. It may look red, brown, or khaki to you.';
      } else if (basicLower == 'brown') {
        confusionWarning = 'Notice: This is actually Brown. It can easily be confused with dark green or red.';
      } else if (basicLower == 'purple') {
        confusionWarning = 'Notice: This is actually Purple. It often looks blue without red perception.';
      } else if (basicLower == 'pink') {
        confusionWarning = 'Notice: This is actually Pink. It may look gray or pale light blue.';
      } else if (basicLower == 'orange') {
        confusionWarning = 'Notice: This is actually Orange. It may appear bright yellow-green to you.';
      }
    } else if (userCvdType == CvdType.tritanopia) {
      if (basicLower == 'blue') {
        confusionWarning = 'Notice: This is actually Blue. It may appear green or dark gray.';
      } else if (basicLower == 'yellow') {
        confusionWarning = 'Notice: This is actually Yellow. It may appear pink or light violet.';
      }
    }

    return ColorMatchResult(
      sampledColor: color,
      basicName: bestBasicName,
      extendedName: bestExtended.name,
      distance: minExtendedDist,
      luminance: luminance,
      isPoorLighting: isPoorLighting,
      lightingWarning: lightingWarning,
      confusionWarning: confusionWarning,
    );
  }

  // --- Curated Color Dictionaries ---

  static const Map<String, List<Color>> _basicColorAnchors = {
    'Red': [Color(0xFFFF0000), Color(0xFFE53935), Color(0xFFB71C1C), Color(0xFFD32F2F)],
    'Orange': [Color(0xFFFF9800), Color(0xFFFB8C00), Color(0xFFF57C00), Color(0xFFFF6F00)],
    'Yellow': [Color(0xFFFFFF00), Color(0xFFFDD835), Color(0xFFFFEB3B), Color(0xFFFBC02D)],
    'Green': [Color(0xFF00FF00), Color(0xFF43A047), Color(0xFF2E7D32), Color(0xFF00C853), Color(0xFF388E3C)],
    'Blue': [Color(0xFF0000FF), Color(0xFF0055FF), Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
    'Purple': [Color(0xFF800080), Color(0xFF8E24AA), Color(0xFF6A1B9A), Color(0xFF4A148C)],
    'Pink': [Color(0xFFFFC0CB), Color(0xFFF06292), Color(0xFFE91E63), Color(0xFFFF4081)],
    'Brown': [Color(0xFF8B4513), Color(0xFF6D4C41), Color(0xFF4E342E), Color(0xFF5D4037)],
    'Black': [Color(0xFF000000), Color(0xFF121212), Color(0xFF212121)],
    'White': [Color(0xFFFFFFFF), Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
    'Gray': [Color(0xFF808080), Color(0xFF9E9E9E), Color(0xFF757575), Color(0xFF616161)],
  };

  static const List<NamedColor> _extendedColors = [
    // Reds & Pinks
    NamedColor(name: 'Crimson', referenceColor: Color(0xFFDC143C), category: 'Extended'),
    NamedColor(name: 'Maroon', referenceColor: Color(0xFF800000), category: 'Extended'),
    NamedColor(name: 'Burgundy', referenceColor: Color(0xFF800020), category: 'Extended'),
    NamedColor(name: 'Coral', referenceColor: Color(0xFFFF7F50), category: 'Extended'),
    NamedColor(name: 'Salmon', referenceColor: Color(0xFFFA8072), category: 'Extended'),
    NamedColor(name: 'Rose Pink', referenceColor: Color(0xFFFF66CC), category: 'Extended'),
    NamedColor(name: 'Magenta', referenceColor: Color(0xFFFF00FF), category: 'Extended'),
    // Oranges & Yellows
    NamedColor(name: 'Amber', referenceColor: Color(0xFFFFBF00), category: 'Extended'),
    NamedColor(name: 'Gold', referenceColor: Color(0xFFFFD700), category: 'Extended'),
    NamedColor(name: 'Peach', referenceColor: Color(0xFFFFDAB9), category: 'Extended'),
    NamedColor(name: 'Beige', referenceColor: Color(0xFFF5F5DC), category: 'Extended'),
    NamedColor(name: 'Khaki', referenceColor: Color(0xFFC3B091), category: 'Extended'),
    // Greens
    NamedColor(name: 'Lime', referenceColor: Color(0xFF00FF00), category: 'Extended'),
    NamedColor(name: 'Olive', referenceColor: Color(0xFF808000), category: 'Extended'),
    NamedColor(name: 'Forest Green', referenceColor: Color(0xFF228B22), category: 'Extended'),
    NamedColor(name: 'Mint', referenceColor: Color(0xFF98FF98), category: 'Extended'),
    NamedColor(name: 'Teal', referenceColor: Color(0xFF008080), category: 'Extended'),
    NamedColor(name: 'Turquoise', referenceColor: Color(0xFF40E0D0), category: 'Extended'),
    NamedColor(name: 'Cyan', referenceColor: Color(0xFF00FFFF), category: 'Extended'),
    // Blues
    NamedColor(name: 'Navy Blue', referenceColor: Color(0xFF000080), category: 'Extended'),
    NamedColor(name: 'Cobalt Blue', referenceColor: Color(0xFF0047AB), category: 'Extended'),
    NamedColor(name: 'Sky Blue', referenceColor: Color(0xFF87CEEB), category: 'Extended'),
    NamedColor(name: 'Indigo', referenceColor: Color(0xFF4B0082), category: 'Extended'),
    // Purples
    NamedColor(name: 'Lavender', referenceColor: Color(0xFFE6E6FA), category: 'Extended'),
    NamedColor(name: 'Violet', referenceColor: Color(0xFFEE82EE), category: 'Extended'),
    NamedColor(name: 'Plum', referenceColor: Color(0xFFDDA0DD), category: 'Extended'),
    // Browns & Grays
    NamedColor(name: 'Tan', referenceColor: Color(0xFFD2B48C), category: 'Extended'),
    NamedColor(name: 'Chocolate', referenceColor: Color(0xFF7B3F00), category: 'Extended'),
    NamedColor(name: 'Charcoal', referenceColor: Color(0xFF36454F), category: 'Extended'),
    NamedColor(name: 'Silver', referenceColor: Color(0xFFC0C0C0), category: 'Extended'),
    NamedColor(name: 'Pure White', referenceColor: Color(0xFFFFFFFF), category: 'Extended'),
    NamedColor(name: 'Jet Black', referenceColor: Color(0xFF000000), category: 'Extended'),
  ];
}
