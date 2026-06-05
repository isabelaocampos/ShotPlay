import 'package:flutter_test/flutter_test.dart';

import 'package:shotplay_app/src/app.dart';
import 'package:shotplay_app/src/data/repositories/local_game_event_repository.dart';
import 'package:shotplay_app/src/data/repositories/local_game_repository.dart';
import 'package:shotplay_app/src/data/repositories/local_game_session_repository.dart';
import 'package:shotplay_app/src/data/repositories/local_room_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final gameSessionRepository = LocalGameSessionRepository();
    await tester.pumpWidget(ShotPlayApp(
      roomRepository: LocalRoomRepository(gameSessionRepository),
      gameRepository: const LocalGameRepository(),
      gameEventRepository: LocalGameEventRepository(),
      gameSessionRepository: gameSessionRepository,
    ));

    expect(find.byType(ShotPlayApp), findsOneWidget);
  });
}
