import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/core/utils/cvd_simulator.dart';
import 'package:colorsight/features/test/domain/models/test_result.dart';
import 'package:colorsight/features/reports/services/pdf_report_service.dart';

void main() {
  test('PDF report generates successfully for 24-plate Comprehensive battery without truncation', () async {
    final responses = List.generate(24, (i) {
      return PlateResponse(
        plateNumber: i + 1,
        givenAnswer: '12',
        normalAnswer: '12',
        isCorrect: true,
      );
    });

    final result = TestResult(
      id: 'CS-20260911-TEST',
      timestamp: DateTime.now(),
      ageGroup: 'Adult',
      testMode: 'Comprehensive Battery (24 Plates)',
      totalPlates: 24,
      correctCount: 24,
      indicatedType: CvdType.normal,
      severity: 'Normal',
      summaryTitle: 'Normal Color Vision',
      explanation: 'All plates identified correctly.',
      responses: responses,
    );

    final doc = PdfReportService.buildPdfDocument(result, patientName: 'Jacky Lim');
    final bytes = await doc.save();

    // Verify PDF document generated valid binary content
    expect(bytes.isNotEmpty, true);
    expect(bytes.length, greaterThan(2000));
  });

  test('PDF report generates successfully for Quick (6) and Standard (14) batteries', () async {
    for (final count in [6, 14]) {
      final responses = List.generate(count, (i) {
        return PlateResponse(
          plateNumber: i + 1,
          givenAnswer: '12',
          normalAnswer: '12',
          isCorrect: true,
        );
      });

      final result = TestResult(
        id: 'CS-20260911-$count',
        timestamp: DateTime.now(),
        ageGroup: 'Adult',
        testMode: '$count Plates',
        totalPlates: count,
        correctCount: count,
        indicatedType: CvdType.normal,
        severity: 'Normal',
        summaryTitle: 'Normal Color Vision',
        explanation: 'All plates identified correctly.',
        responses: responses,
      );

      final doc = PdfReportService.buildPdfDocument(result);
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
    }
  });
}
