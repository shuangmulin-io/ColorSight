import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../test/domain/models/test_result.dart';

class TestHistoryRepository {
  static const _keyLatestResult = 'colorsight_latest_test_result';
  static const _keyHistory = 'colorsight_test_history';

  /// Maximum historical test records retained locally to prevent unbounded storage growth
  static const int maxHistoryItems = 50;

  /// Save the latest test result with bounded FIFO retention
  Future<void> saveResult(TestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(result.toJson());
    await prefs.setString(_keyLatestResult, jsonStr);

    // Append to history list and enforce bounded FIFO retention limit
    final history = await getHistory();
    history.insert(0, result);
    final boundedHistory = history.take(maxHistoryItems).toList();
    final historyListJson = jsonEncode(boundedHistory.map((r) => r.toJson()).toList());
    await prefs.setString(_keyHistory, historyListJson);
  }

  /// Get the latest test result (used for cross-feature color ID warnings)
  Future<TestResult?> getLatestResult() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyLatestResult);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return TestResult.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Get all test history
  Future<List<TestResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyHistory);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) => TestResult.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Clear all stored test history and latest result
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLatestResult);
    await prefs.remove(_keyHistory);
  }
}
