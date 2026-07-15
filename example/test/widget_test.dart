import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomePage shows usage sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('et_date_picker'), findsOneWidget);
    expect(find.text('How to use'), findsOneWidget);
    expect(find.text('Pick a date for your API'), findsOneWidget);
    expect(find.text('Choose Ethiopian date'), findsOneWidget);
    expect(find.text('Current date & time'), findsOneWidget);
    expect(find.text('Time conversion'), findsOneWidget);
    expect(find.text('Minimal'), findsOneWidget);
    expect(find.text('Birth date'), findsOneWidget);
  });
}
