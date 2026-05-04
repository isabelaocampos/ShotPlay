import 'package:shotplay_app/src/features/ingresar_codigo/domain/model/ingresar_codigo_user.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/domain/repository/ingresar_codigo_repository.dart';

class GetIngresarCodigoUserUsecase {
  final IngresarCodigoRepository _repository;

  const GetIngresarCodigoUserUsecase(this._repository);

  Future<IngresarCodigoUser?> execute(String userId) {
    return _repository.getIngresarCodigoUser(userId);
  }
}
