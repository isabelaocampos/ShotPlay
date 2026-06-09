import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';
import 'package:shotplay_app/src/features/enter_code/domain/repository/enter_code_repository.dart';

class GetEnterCodeUserUsecase {
  final EnterCodeRepository _repository;

  const GetEnterCodeUserUsecase(this._repository);

  Future<EnterCodeUser?> execute(String userId) {
    return _repository.getEnterCodeUser(userId);
  }
}
