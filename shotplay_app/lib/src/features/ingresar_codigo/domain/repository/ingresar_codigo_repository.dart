import 'package:shotplay_app/src/features/ingresar_codigo/domain/model/ingresar_codigo_user.dart';

abstract class IngresarCodigoRepository {
  Future<IngresarCodigoUser?> getIngresarCodigoUser(String userId);
}
