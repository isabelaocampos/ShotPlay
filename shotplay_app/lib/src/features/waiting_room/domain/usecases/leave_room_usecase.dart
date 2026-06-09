import '../../../../domain/repositories/room_repository.dart';

class LeaveRoomUsecase {
  const LeaveRoomUsecase(this._repository);

  final RoomRepository _repository;

  Future<void> execute(int roomId) => _repository.leaveRoom(roomId);
}
