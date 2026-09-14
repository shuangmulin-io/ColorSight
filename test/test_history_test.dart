import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colorsight/core/utils/cvd_simulator.dart';
import 'package:colorsight/features/test/domain/models/test_result.dart';
import 'package:colorsight/features/results/data/test_history_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TestHistoryRepository Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves latest result and retrieves empty history initially', () async {
      final repo = TestHistoryRepository();
      final initialHistory = await repo.getHistory();
      expect(initialHistory, isEmpty);

      final result = TestResult(
        id: 'test-1',
        timestamp: DateTime(2026, 9, 14, 12, 0),
        ageGroup: 'Adult',
        totalPlates: 14,
        correctCount: 14,
        indicatedType: CvdType.normal,
        severity: 'Normal',
        summaryTitle: 'Normal Vision',
        explanation: 'No color vision deficiency detected.',
        responses: const [],
      );

      await repo.saveResult(result);

      final latest = await repo.getLatestResult();
      expect(latest?.id, 'test-1');

      final history = await repo.getHistory();
      expect(history.length, 1);
      expect(history.first.id, 'test-1');
    });

    test('Enforces bounded FIFO retention cap at maxHistoryItems (50)', () async {
      final repo = TestHistoryRepository();

      // Save 55 test results
      for (int i = 0; i < 55; i++) {
        final result = TestResult(
          id: 'test-$i',
          timestamp: DateTime(2026, 9, 14, 12, 0).add(Duration(minutes: i)),
          ageGroup: 'Adult',
          totalPlates: 14,
          correctCount: 14,
          indicatedType: CvdType.normal,
          severity: 'Normal',
          summaryTitle: 'Normal Vision',
          explanation: 'No color vision deficiency detected.',
          responses: const [],
        );
        await repo.saveResult(result);
      }

      final history = await repo.getHistory();

      // Verify retention cap is exactly 50
      expect(history.length, TestHistoryRepository.maxHistoryItems);
      expect(history.length, 50);

      // Verify FIFO ordering: most recent (test-54) is at index 0
      expect(history.first.id, 'test-54');

      // Verify oldest retained is test-5 (0..4 were evicted)
      expect(history.last.id, 'test-5');
    });

    test('Clears all history and latest result cleanly', () async {
      final repo = TestHistoryRepository();
      final result = TestResult(
        id: 'test-1',
        timestamp: DateTime(2026, 9, 14, 12, 0),
        ageGroup: 'Adult',
        totalPlates: 14,
        correctCount: 14,
        indicatedType: CvdType.normal,
        severity: 'Normal',
        summaryTitle: 'Normal Vision',
        explanation: 'No color vision deficiency detected.',
        responses: const [],
      );

      await repo.saveResult(result);
      expect((await repo.getHistory()).length, 1);
      expect((await repo.getLatestResult())?.id, 'test-1');

      await repo.clearHistory();
      expect(await repo.getHistory(), isEmpty);
      expect(await repo.getLatestResult(), isNull);
    });
  });
}
