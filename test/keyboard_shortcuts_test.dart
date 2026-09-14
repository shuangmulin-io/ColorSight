import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colorsight/features/test/domain/models/test_mode.dart';
import 'package:colorsight/features/test/presentation/screens/ishihara_test_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('IshiharaTestScreen responds to physical keyboard inputs (0-9, Backspace, Space)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IshiharaTestScreen(mode: TestBatteryMode.quick),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initially empty input prompt
    expect(find.text('Tap a number below'), findsOneWidget);

    // Press physical key '1'
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '1');

    // Press physical key '2' -> should show '12'
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '12');

    // Press Backspace -> should remove '2', leaving '1'
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '1');

    // Press Backspace again -> should clear back to 'Tap a number below'
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(find.text('Tap a number below'), findsOneWidget);

    // Press Space -> should trigger "Nothing" and advance to Plate 2
    expect(find.text('Plate 1 of 6'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Plate 2 of 6'), findsOneWidget);

    // Plate 2: Type '7', '4', then press Enter to submit
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '74');

    // Type 3rd digit -> should show 749 (max 3 digits)
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '749');

    // Type 4th digit -> should remain 749 (capped at 3 digits)
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '749');

    // Press Enter to submit -> advance to Plate 3
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Plate 3 of 6'), findsOneWidget);

    // Plate 3: Press 'N' -> trigger Nothing and advance to Plate 4
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.text('Plate 4 of 6'), findsOneWidget);

    // Plate 4: Test numpad keys
    await tester.sendKeyEvent(LogicalKeyboardKey.numpad5);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('answer_display_text'))).data, '5');

    await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
    await tester.pumpAndSettle();
    expect(find.text('Plate 5 of 6'), findsOneWidget);
  });
}
