import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/core/utils/cielab.dart';
import 'package:colorsight/core/utils/cvd_simulator.dart';
import 'package:colorsight/features/test/domain/models/plate_data.dart';
import 'package:colorsight/features/test/domain/models/test_mode.dart';
import 'package:colorsight/features/test/domain/services/plate_generator.dart';

void main() {
  group('PRD §5.2 Automated Brettel/Viénot Simulation QA Check', () {
    late List<PlateData> plates;

    setUp(() {
      plates = PlateGenerator.generateAdultBattery(seed: 42, shuffle: false);
    });

    test('All 14 plates generate with valid non-empty dots', () {
      expect(plates.length, 14);
      for (final plate in plates) {
        expect(plate.dots.isNotEmpty, true, reason: 'Plate ${plate.plateNumber} has no dots');
        expect(plate.dots.any((d) => d.isForeground), true,
            reason: 'Plate ${plate.plateNumber} has no foreground dots');
        expect(plate.dots.any((d) => !d.isForeground), true,
            reason: 'Plate ${plate.plateNumber} has no background dots');
      }
    });

    test('Omitting seed dynamically randomizes dot arrangements across runs', () {
      final run1 = PlateGenerator.generateAdultBattery(seed: 100, shuffle: false);
      final run2 = PlateGenerator.generateAdultBattery(seed: 200, shuffle: false);
      expect(
        run1[0].dots.first.x != run2[0].dots.first.x || run1[0].dots.first.y != run2[0].dots.first.y,
        true,
        reason: 'Dot layouts must vary across different seeds',
      );
    });

    test('Shuffling preserves Plate 1 as demonstration and randomizes the rest', () {
      final shuffled1 = PlateGenerator.generateAdultBattery(seed: 123, shuffle: true);
      final shuffled2 = PlateGenerator.generateAdultBattery(seed: 456, shuffle: true);

      // Plate 1 must always be demonstration plate
      expect(shuffled1.first.plateNumber, 1);
      expect(shuffled2.first.plateNumber, 1);

      // Subsequent presentation order must vary
      final order1 = shuffled1.sublist(1).map((p) => p.plateNumber).toList();
      final order2 = shuffled2.sublist(1).map((p) => p.plateNumber).toList();
      expect(order1, isNot(equals(order2)));
    });

    test('Battery modes generate accurate plate counts (Quick: 6, Standard: 14, Comprehensive: 24)', () {
      final quick = PlateGenerator.generateBattery(mode: TestBatteryMode.quick, shuffle: false);
      final standard = PlateGenerator.generateBattery(mode: TestBatteryMode.standard, shuffle: false);
      final comprehensive = PlateGenerator.generateBattery(mode: TestBatteryMode.comprehensive, shuffle: false);

      expect(quick.length, 6);
      expect(standard.length, 14);
      expect(comprehensive.length, 24);

      // Verify comprehensive plates all have non-empty dots
      for (final p in comprehensive) {
        expect(p.dots.isNotEmpty, true, reason: 'Plate ${p.plateNumber} must have dots');
      }
    });

    test('Plate 1 (Demonstration) maintains high contrast under all vision types', () {
      final demoPlate = plates[0];
      final fgDot = demoPlate.dots.firstWhere((d) => d.isForeground);
      final bgDot = demoPlate.dots.firstWhere((d) => !d.isForeground);

      // Normal contrast
      final normalDeltaE = CieLab.fromColor(fgDot.color).deltaE(CieLab.fromColor(bgDot.color));
      expect(normalDeltaE, greaterThan(35.0), reason: 'Demonstration plate normal contrast too low');

      // Protanopia contrast
      final protanFg = CvdSimulator.simulate(fgDot.color, CvdType.protanopia);
      final protanBg = CvdSimulator.simulate(bgDot.color, CvdType.protanopia);
      final protanDeltaE = CieLab.fromColor(protanFg).deltaE(CieLab.fromColor(protanBg));
      expect(protanDeltaE, greaterThan(25.0), reason: 'Demo plate must stay clearly visible to Protan');

      // Deuteranopia contrast
      final deutanFg = CvdSimulator.simulate(fgDot.color, CvdType.deuteranopia);
      final deutanBg = CvdSimulator.simulate(bgDot.color, CvdType.deuteranopia);
      final deutanDeltaE = CieLab.fromColor(deutanFg).deltaE(CieLab.fromColor(deutanBg));
      expect(deutanDeltaE, greaterThan(25.0), reason: 'Demo plate must stay clearly visible to Deutan');
    });

    test('Red-Green plates exhibit significant contrast drop under simulated Deuteranopia', () {
      // Plate 4 is a classic red-green vanishing plate (Normal sees 5, CVD sees nothing)
      final vanishingPlate = plates[3];
      final fgDots = vanishingPlate.dots.where((d) => d.isForeground).take(10).toList();
      final bgDots = vanishingPlate.dots.where((d) => !d.isForeground).take(10).toList();

      double normalContrastSum = 0;
      double deutanContrastSum = 0;

      for (int i = 0; i < fgDots.length; i++) {
        final fg = fgDots[i].color;
        final bg = bgDots[i].color;

        final normalDE = CieLab.fromColor(fg).deltaE(CieLab.fromColor(bg));
        final simFg = CvdSimulator.simulate(fg, CvdType.deuteranopia);
        final simBg = CvdSimulator.simulate(bg, CvdType.deuteranopia);
        final deutanDE = CieLab.fromColor(simFg).deltaE(CieLab.fromColor(simBg));

        normalContrastSum += normalDE;
        deutanContrastSum += deutanDE;
      }

      final avgNormal = normalContrastSum / fgDots.length;
      final avgDeutan = deutanContrastSum / fgDots.length;

      // Normal vision sees clear high chromatic contrast
      expect(avgNormal, greaterThan(25.0), reason: 'Normal trichromats must see high contrast');
      // Under simulated deuteranopia, chromatic contrast drops substantially
      expect(avgDeutan, lessThan(avgNormal * 0.60),
          reason: 'Simulated deuteranope contrast must drop significantly below normal');
    });

    test('Plate 14 (Tritan) exhibits contrast drop under simulated Tritanopia', () {
      final tritanPlate = plates[13];
      final fgDot = tritanPlate.dots.firstWhere((d) => d.isForeground);
      final bgDot = tritanPlate.dots.firstWhere((d) => !d.isForeground);

      final normalDE = CieLab.fromColor(fgDot.color).deltaE(CieLab.fromColor(bgDot.color));
      final simFg = CvdSimulator.simulate(fgDot.color, CvdType.tritanopia);
      final simBg = CvdSimulator.simulate(bgDot.color, CvdType.tritanopia);
      final tritanDE = CieLab.fromColor(simFg).deltaE(CieLab.fromColor(simBg));

      expect(normalDE, greaterThan(40.0));
      expect(tritanDE, lessThan(normalDE * 0.50));
    });
  });
}
