// Smoke test placeholder. Replace with feature-specific tests
// (auth, game catalog, create room, waiting room) as the app grows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders placeholder smoke widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('ShotPlay'))),
      ),
    );

    expect(find.text('ShotPlay'), findsOneWidget);
  });
}
