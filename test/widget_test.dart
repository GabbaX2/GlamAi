import 'package:flutter_test/flutter_test.dart';
import 'package:glam_ai/main.dart';

void main() {
  testWidgets('Glam AI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GlamAIApp());

    // Verify the app starts with splash screen
    expect(find.text('GLAM AI'), findsOneWidget);
  });
}
