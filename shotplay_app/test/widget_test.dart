// Smoke test placeholder. Reemplaza con pruebas específicas de cada feature
// (catálogo de juegos, configurar sala, sala de espera, etc.) a medida que
// la app crece.

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
