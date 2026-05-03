import 'package:flutter_test/flutter_test.dart';

import 'package:shotplay_app/src/app.dart';
import 'package:shotplay_app/src/data/repositories/local_game_repository.dart';
import 'package:shotplay_app/src/data/repositories/local_room_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShotPlayApp(
      roomRepository: LocalRoomRepository(),
      gameRepository: LocalGameRepository(),
      currentAdminId: 'demo-admin',
    ));

    expect(find.byType(ShotPlayApp), findsOneWidget);
  });
}
