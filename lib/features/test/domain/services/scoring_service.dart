import 'package:intl/intl.dart';
import '../models/test_result.dart';
import '../../../../core/utils/cvd_simulator.dart';

class ScoringService {
  /// Analyzes responses from the test battery and derives the clinical screening result
  static TestResult evaluateAdultBattery(
    List<PlateResponse> responses, {
    String testMode = 'Standard Screening (14 Plates)',
  }) {
    final now = DateTime.now();
    final id = 'CS-${DateFormat('yyyyMMdd-HHmmss').format(now)}';
    final totalPlates = responses.length;
    int correctCount = 0;

    int redGreenErrors = 0;
    int protanIndications = 0;
    int deutanIndications = 0;
    bool tritanMissed = false;
    bool controlPassed = true;

    for (final resp in responses) {
      if (resp.isCorrect) {
        correctCount++;
      } else {
        if (resp.plateNumber == 1) {
          controlPassed = false;
        } else if (resp.plateNumber == 14 || resp.plateNumber == 24) {
          tritanMissed = true;
        } else if ((resp.plateNumber >= 11 && resp.plateNumber <= 13) || resp.plateNumber == 21) {
          // Diagnostic plates
          if (resp.protanAnswer != null && resp.givenAnswer == resp.protanAnswer) {
            protanIndications++;
          } else if (resp.deutanAnswer != null && resp.givenAnswer == resp.deutanAnswer) {
            deutanIndications++;
          } else {
            redGreenErrors++;
          }
        } else {
          redGreenErrors++;
        }
      }
    }

    CvdType indicatedType = CvdType.normal;
    String severity = "Normal";
    String summaryTitle = "Normal Color Vision";
    String explanation = "Your responses match typical trichromatic color perception. You correctly identified the numbers and patterns across red-green and blue-yellow screening plates.";

    final int rgErrorThreshold;
    final int diagnosticThreshold;
    if (totalPlates <= 6) {
      rgErrorThreshold = 1;
      diagnosticThreshold = 1;
    } else if (totalPlates <= 14) {
      rgErrorThreshold = 3;
      diagnosticThreshold = 2;
    } else {
      rgErrorThreshold = 5;
      diagnosticThreshold = 2;
    }

    if (!controlPassed) {
      summaryTitle = "Inconclusive / Check Screen Setup";
      explanation = "You missed the demonstration plate (Plate 1), which is designed to be visible to all color vision types. This usually indicates inadequate screen brightness, an active Night Shift/blue-light filter, or heavy glare. Please check your screen settings and re-take the test.";
      severity = "Inconclusive";
      indicatedType = CvdType.normal;
    } else if (tritanMissed && redGreenErrors <= (totalPlates <= 6 ? 0 : 2)) {
      indicatedType = CvdType.tritanopia;
      severity = "Screening Indication";
      summaryTitle = "Tritan (Blue-Yellow) Deficiency Indicated";
      explanation = "Your responses suggest difficulty discriminating between blue and yellow/violet shades. Tritan deficiency is less common and can be congenital or acquired.";
    } else if (redGreenErrors >= rgErrorThreshold || (protanIndications + deutanIndications) >= diagnosticThreshold) {
      // Red-Green deficiency
      if (protanIndications > deutanIndications) {
        indicatedType = CvdType.protanopia;
        summaryTitle = "Protan (Red-Weak / Red-Blind) Indicated";
        explanation = "Responses on the diagnostic plates specifically indicate Protan vision deficiency (Protanomaly or Protanopia). Red cones in your retina are reduced or absent, making red, orange, and dark green easily confused.";
      } else {
        // Deutan is far more common (~75% of red-green CVD)
        indicatedType = CvdType.deuteranopia;
        summaryTitle = "Deutan (Green-Weak / Green-Blind) Indicated";
        explanation = "Responses on the diagnostic plates indicate Deuteranomaly or Deuteranopia (the most common form of color vision deficiency). Green cones are shifted or absent, causing red, green, brown, and olive tones to blend together.";
      }

      // Severity estimate based on error proportion
      final effectivePlates = totalPlates > 2 ? totalPlates - 2 : 1;
      final double errorRate = redGreenErrors / effectivePlates;
      if (errorRate >= 0.55) {
        severity = "Strong";
      } else if (errorRate >= 0.30) {
        severity = "Moderate";
      } else {
        severity = "Mild";
      }
    }

    return TestResult(
      id: id,
      timestamp: now,
      ageGroup: "Adult",
      testMode: testMode,
      totalPlates: totalPlates,
      correctCount: correctCount,
      indicatedType: indicatedType,
      severity: severity,
      summaryTitle: summaryTitle,
      explanation: explanation,
      responses: responses,
    );
  }
}
