enum RoomLifecycleStatus {
  waiting,
  inProgress,
  finished;

  static RoomLifecycleStatus fromDb(String? value) {
    switch (value) {
      case 'in_progress':
        return RoomLifecycleStatus.inProgress;
      case 'finished':
        return RoomLifecycleStatus.finished;
      case 'waiting':
      default:
        return RoomLifecycleStatus.waiting;
    }
  }

  String toDb() {
    switch (this) {
      case RoomLifecycleStatus.waiting:
        return 'waiting';
      case RoomLifecycleStatus.inProgress:
        return 'in_progress';
      case RoomLifecycleStatus.finished:
        return 'finished';
    }
  }
}
