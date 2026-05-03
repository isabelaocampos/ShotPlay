import 'package:flutter_test/flutter_test.dart';
import 'package:shotplay_app/src/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ShotPlayApp());
    // Smoke test: the widget tree builds without throwing.
    expect(find.byType(ShotPlayApp), findsOneWidget);
  });
}
