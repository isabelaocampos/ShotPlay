class ParticipationStatuses {
  ParticipationStatuses._();

  static const String active = 'active';
  static const String disconnected = 'disconnected';
  static const String left = 'left';

  static bool occupiesSlot(String? status) {
    return status == active || status == disconnected;
  }

  static bool isConnected(String? status) => status == active;
}
