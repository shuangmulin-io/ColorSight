import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/features/color_id/presentation/screens/photo_color_picker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboardContent;

  setUp(() {
    clipboardContent = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        clipboardContent = (methodCall.arguments as Map<dynamic, dynamic>)['text'] as String?;
        return null;
      } else if (methodCall.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboardContent};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('PhotoColorPickerScreen copies color details to clipboard on button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PhotoColorPickerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify copy button and color tap target are present
    expect(find.byKey(const Key('copy_color_button')), findsOneWidget);
    expect(find.byKey(const Key('color_info_tap_target')), findsOneWidget);

    // Initial color is Red (#E53935)
    // Tap the copy icon button
    await tester.tap(find.byKey(const Key('copy_color_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify confirmation SnackBar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Copied'), findsOneWidget);

    // Verify clipboard content contains color name, hex, and RGB
    expect(clipboardContent, isNotNull);
    expect(clipboardContent, contains('#E53935'));
    expect(clipboardContent, contains('RGB(229, 57, 53)'));

    // Wait for SnackBar to dismiss
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    // Toggle to Specific / Extended Names
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Tap the text info tap target directly
    await tester.tap(find.byKey(const Key('color_info_tap_target')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(clipboardContent, isNotNull);
    expect(clipboardContent, contains('#E53935'));
    expect(clipboardContent, contains('RGB(229, 57, 53)'));
  });
}
