import '../../../../core/utils/cvd_simulator.dart';

class PlateResponse {
  final int plateNumber;
  final String givenAnswer;
  final String normalAnswer;
  final bool isCorrect;
  final String? cvdAnswer;
  final String? protanAnswer;
  final String? deutanAnswer;

  const PlateResponse({
    required this.plateNumber,
    required this.givenAnswer,
    required this.normalAnswer,
    required this.isCorrect,
    this.cvdAnswer,
    this.protanAnswer,
    this.deutanAnswer,
  });

  Map<String, dynamic> toJson() => {
        'plateNumber': plateNumber,
        'givenAnswer': givenAnswer,
        'normalAnswer': normalAnswer,
        'isCorrect': isCorrect,
      };

  factory PlateResponse.fromJson(Map<String, dynamic> json) => PlateResponse(
        plateNumber: json['plateNumber'] as int,
        givenAnswer: json['givenAnswer'] as String,
        normalAnswer: json['normalAnswer'] as String,
        isCorrect: json['isCorrect'] as bool,
      );
}

class TestResult {
  final String id;
  final DateTime timestamp;
  final String ageGroup; // "Adult" or "Kids"
  final String testMode;
  final int totalPlates;
  final int correctCount;
  final CvdType indicatedType;
  final String severity; // "Normal", "Mild", "Moderate", "Strong"
  final String summaryTitle;
  final String explanation;
  final List<PlateResponse> responses;

  const TestResult({
    required this.id,
    required this.timestamp,
    required this.ageGroup,
    this.testMode = 'Standard Screening (14 Plates)',
    required this.totalPlates,
    required this.correctCount,
    required this.indicatedType,
    required this.severity,
    required this.summaryTitle,
    required this.explanation,
    required this.responses,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'ageGroup': ageGroup,
        'testMode': testMode,
        'totalPlates': totalPlates,
        'correctCount': correctCount,
        'indicatedType': indicatedType.name,
        'severity': severity,
        'summaryTitle': summaryTitle,
        'explanation': explanation,
        'responses': responses.map((r) => r.toJson()).toList(),
      };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        ageGroup: json['ageGroup'] as String,
        testMode: (json['testMode'] as String?) ?? 'Standard Screening (14 Plates)',
        totalPlates: json['totalPlates'] as int,
        correctCount: json['correctCount'] as int,
        indicatedType: CvdType.values.firstWhere(
          (e) => e.name == json['indicatedType'],
          orElse: () => CvdType.normal,
        ),
        severity: json['severity'] as String,
        summaryTitle: json['summaryTitle'] as String,
        explanation: json['explanation'] as String,
        responses: (json['responses'] as List)
            .map((r) => PlateResponse.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
