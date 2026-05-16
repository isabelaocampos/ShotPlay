class RoomCodeConstants {
  RoomCodeConstants._();

  static const int length = 6;

  static final RegExp pattern = RegExp(r'^[A-Z0-9]{6}$');

  static String normalize(String raw) => raw.trim().toUpperCase();

  static bool isValid(String raw) => pattern.hasMatch(normalize(raw));
}
