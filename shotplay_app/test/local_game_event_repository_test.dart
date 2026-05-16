import 'package:flutter_test/flutter_test.dart';
import 'package:shotplay_app/src/data/repositories/local_game_event_repository.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';

void main() {
  group('LocalGameEventRepository', () {
    test('emitEvent delivers payload to listenToEvents', () async {
      final repo = LocalGameEventRepository();
      await repo.connect('ABC123');

      final received = <Map<String, dynamic>>[];
      final sub = repo.listenToEvents().listen(received.add);

      await repo.emitEvent(<String, dynamic>{
        'type': 'player_joined',
        'payload': <String, dynamic>{'username': 'Juan'},
      });

      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first['type'], 'player_joined');
      expect(received.first['payload'], {'username': 'Juan'});

      await sub.cancel();
      await repo.disconnect();
    });

    test('disconnect stops delivery until reconnected', () async {
      final repo = LocalGameEventRepository();
      await repo.connect('ROOM1');

      final received = <Map<String, dynamic>>[];
      var sub = repo.listenToEvents().listen(received.add);

      await repo.emitEvent(<String, dynamic>{'type': 'before'});
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(1));

      await sub.cancel();
      await repo.disconnect();
      expect(
        () => repo.emitEvent(<String, dynamic>{'type': 'after'}),
        throwsA(isA<GameEventNotConnectedException>()),
      );

      await repo.connect('ROOM1');
      sub = repo.listenToEvents().listen(received.add);
      await repo.emitEvent(<String, dynamic>{'type': 'after_reconnect'});
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(2));
      expect(received.last['type'], 'after_reconnect');

      await sub.cancel();
      await repo.disconnect();
    });

    test('emitEvent throws when not connected', () async {
      final repo = LocalGameEventRepository();

      expect(
        () => repo.emitEvent(<String, dynamic>{'type': 'ping'}),
        throwsA(isA<GameEventNotConnectedException>()),
      );
    });

    test('two clients in same room receive each other events', () async {
      final publisher = LocalGameEventRepository();
      final subscriber = LocalGameEventRepository();

      await publisher.connect('SHARED');
      await subscriber.connect('SHARED');

      final received = <Map<String, dynamic>>[];
      final sub = subscriber.listenToEvents().listen(received.add);

      await publisher.emitEvent(<String, dynamic>{
        'type': 'turn_changed',
        'payload': <String, dynamic>{'playerId': 'p1'},
      });

      await Future<void>.delayed(Duration.zero);

      expect(received.single['type'], 'turn_changed');

      await sub.cancel();
      await publisher.disconnect();
      await subscriber.disconnect();
    });
  });
}
