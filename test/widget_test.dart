import 'package:flutter_test/flutter_test.dart';
import 'package:colorsight/main.dart';

void main() {
  testWidgets('ColorSight App renders Home screen with mode selection cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ColorSightApp());
    await tester.pumpAndSettle();

    expect(find.text('ColorSight'), findsWidgets);
    expect(find.text('Adult Screening Test'), findsOneWidget);
    expect(find.text('6, 14, or 24 Plates'), findsOneWidget);
    expect(find.text('Color Identifier'), findsOneWidget);
  });
}
