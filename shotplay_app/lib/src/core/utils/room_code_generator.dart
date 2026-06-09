import 'dart:math';

class RoomCodeGenerator {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  RoomCodeGenerator._();

  static String generate({int length = 6}) {
    final random = Random.secure();
    return List.generate(
      length.clamp(4, 6),
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
  }
}