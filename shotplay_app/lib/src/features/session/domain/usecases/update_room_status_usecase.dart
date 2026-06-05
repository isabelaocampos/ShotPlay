import 'package:shotplay_app/src/domain/entities/room_lifecycle_status.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class UpdateRoomStatusUsecase {
  const UpdateRoomStatusUsecase(this._repository);

  final RoomRepository _repository;

  Future<void> execute(int roomId, RoomLifecycleStatus status) =>
      _repository.updateRoomStatus(roomId, status);
}
