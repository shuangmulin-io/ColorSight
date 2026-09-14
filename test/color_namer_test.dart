import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/core/utils/cvd_simulator.dart';
import 'package:colorsight/features/color_id/domain/services/color_namer.dart';

void main() {
  group('ColorNamer Engine Tests', () {
    test('Identifies pure primary colors accurately', () {
      final redMatch = ColorNamer.identify(const Color(0xFFFF0000));
      expect(redMatch.basicName, 'Red');

      final greenMatch = ColorNamer.identify(const Color(0xFF00FF00));
      expect(greenMatch.basicName, 'Green');

      final blueMatch = ColorNamer.identify(const Color(0xFF0000FF));
      expect(blueMatch.basicName, 'Blue');

      final yellowMatch = ColorNamer.identify(const Color(0xFFFFFF00));
      expect(yellowMatch.basicName, 'Yellow');
    });

    test('Identifies extended nuances when specific names are queried', () {
      final navyMatch = ColorNamer.identify(const Color(0xFF000080));
      expect(navyMatch.extendedName, 'Navy Blue');

      final oliveMatch = ColorNamer.identify(const Color(0xFF808000));
      expect(oliveMatch.extendedName, 'Olive');

      final tealMatch = ColorNamer.identify(const Color(0xFF008080));
      expect(tealMatch.extendedName, 'Teal');
    });

    test('Flags low luminance and high glare thresholds correctly', () {
      final darkColor = ColorNamer.identify(const Color(0xFF101010));
      expect(darkColor.isPoorLighting, true);
      expect(darkColor.lightingWarning?.contains('dim'), true);

      final brightColor = ColorNamer.identify(const Color(0xFFFAFAFA));
      expect(brightColor.isPoorLighting, true);
      expect(brightColor.lightingWarning?.contains('glare'), true);

      final midColor = ColorNamer.identify(const Color(0xFF38BDF8));
      expect(midColor.isPoorLighting, false);
      expect(midColor.lightingWarning, null);
    });

    test('Triggers personalized confusion warning when user profile has Deuteranopia', () {
      // For a red color, a user with deuteranopia should receive a warning
      final redWithDeutan = ColorNamer.identify(
        const Color(0xFFDC2626),
        userCvdType: CvdType.deuteranopia,
      );

      expect(redWithDeutan.confusionWarning != null, true);
      expect(redWithDeutan.confusionWarning!.contains('actually Red'), true);
      expect(redWithDeutan.confusionWarning!.contains('green'), true);

      // For normal vision, no confusion warning is emitted
      final redNormal = ColorNamer.identify(
        const Color(0xFFDC2626),
        userCvdType: CvdType.normal,
      );
      expect(redNormal.confusionWarning, null);
    });
  });
}
