import '../../../../domain/repositories/room_repository.dart';

class CloseRoomUsecase {
  const CloseRoomUsecase(this._repository);

  final RoomRepository _repository;

  Future<void> execute(int roomId) => _repository.closeRoom(roomId);
}
