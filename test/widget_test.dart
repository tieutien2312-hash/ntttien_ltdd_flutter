import 'package:flutter_test/flutter_test.dart';
import 'package:nguyen_thi_thuy_tien/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify app starts up
    expect(find.byType(MyApp), findsOneWidget);
  });
}
