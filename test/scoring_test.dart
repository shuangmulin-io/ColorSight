import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/core/utils/cvd_simulator.dart';
import 'package:colorsight/features/test/domain/models/test_result.dart';
import 'package:colorsight/features/test/domain/services/scoring_service.dart';

void main() {
  group('ScoringService Tests', () {
    test('All correct responses classify as Normal Color Vision', () {
      final responses = List.generate(14, (i) {
        return PlateResponse(
          plateNumber: i + 1,
          givenAnswer: '12',
          normalAnswer: '12',
          isCorrect: true,
        );
      });

      final result = ScoringService.evaluateAdultBattery(responses);
      expect(result.indicatedType, CvdType.normal);
      expect(result.severity, 'Normal');
      expect(result.correctCount, 14);
    });

    test('Failing plate 1 marks test as Inconclusive / Check Screen', () {
      final responses = List.generate(14, (i) {
        return PlateResponse(
          plateNumber: i + 1,
          givenAnswer: i == 0 ? 'nothing' : 'correct',
          normalAnswer: 'correct',
          isCorrect: i != 0,
        );
      });

      final result = ScoringService.evaluateAdultBattery(responses);
      expect(result.severity, 'Inconclusive');
      expect(result.summaryTitle.contains('Check Screen Setup'), true);
    });

    test('Classic Deuteranopia response pattern classifies correctly', () {
      final responses = List.generate(14, (i) {
        final plateNum = i + 1;
        if (plateNum == 1) {
          return const PlateResponse(
            plateNumber: 1,
            givenAnswer: '12',
            normalAnswer: '12',
            isCorrect: true,
          );
        } else if (plateNum >= 11 && plateNum <= 13) {
          // Diagnostic plates: Deutan sees digit 2, 4, 3
          final deutanAnswer = plateNum == 11 ? '2' : (plateNum == 12 ? '4' : '3');
          return PlateResponse(
            plateNumber: plateNum,
            givenAnswer: deutanAnswer,
            normalAnswer: '26',
            isCorrect: false,
            deutanAnswer: deutanAnswer,
            protanAnswer: '6',
          );
        } else {
          // Missing multiple red-green plates
          return PlateResponse(
            plateNumber: plateNum,
            givenAnswer: 'nothing',
            normalAnswer: 'something',
            isCorrect: false,
          );
        }
      });

      final result = ScoringService.evaluateAdultBattery(responses);
      expect(result.indicatedType, CvdType.deuteranopia);
      expect(result.summaryTitle.contains('Deutan'), true);
      expect(['Moderate', 'Strong'].contains(result.severity), true);
    });

    test('Tritan missing plate 14 classifies as Tritanopia', () {
      final responses = List.generate(14, (i) {
        final plateNum = i + 1;
        final isCorrect = plateNum != 14;
        return PlateResponse(
          plateNumber: plateNum,
          givenAnswer: isCorrect ? 'correct' : 'nothing',
          normalAnswer: 'correct',
          isCorrect: isCorrect,
        );
      });

      final result = ScoringService.evaluateAdultBattery(responses);
      expect(result.indicatedType, CvdType.tritanopia);
      expect(result.summaryTitle.contains('Tritan'), true);
    });

    test('Quick battery (6 plates) evaluates correctly', () {
      final responses = [
        const PlateResponse(plateNumber: 1, givenAnswer: '12', normalAnswer: '12', isCorrect: true),
        const PlateResponse(plateNumber: 2, givenAnswer: '3', normalAnswer: '8', isCorrect: false),
        const PlateResponse(plateNumber: 3, givenAnswer: '70', normalAnswer: '29', isCorrect: false),
        const PlateResponse(plateNumber: 4, givenAnswer: 'nothing', normalAnswer: '5', isCorrect: false),
        const PlateResponse(plateNumber: 11, givenAnswer: '2', normalAnswer: '26', deutanAnswer: '2', protanAnswer: '6', isCorrect: false),
        const PlateResponse(plateNumber: 14, givenAnswer: '16', normalAnswer: '16', isCorrect: true),
      ];

      final result = ScoringService.evaluateAdultBattery(responses, testMode: 'Quick Check (6 Plates)');
      expect(result.totalPlates, 6);
      expect(result.indicatedType, CvdType.deuteranopia);
      expect(result.testMode, 'Quick Check (6 Plates)');
    });

    test('Comprehensive battery (24 plates) normal responses classify cleanly', () {
      final responses = List.generate(24, (i) {
        return PlateResponse(
          plateNumber: i + 1,
          givenAnswer: 'correct',
          normalAnswer: 'correct',
          isCorrect: true,
        );
      });

      final result = ScoringService.evaluateAdultBattery(responses, testMode: 'Comprehensive Battery (24 Plates)');
      expect(result.totalPlates, 24);
      expect(result.correctCount, 24);
      expect(result.indicatedType, CvdType.normal);
      expect(result.severity, 'Normal');
    });
  });
}
