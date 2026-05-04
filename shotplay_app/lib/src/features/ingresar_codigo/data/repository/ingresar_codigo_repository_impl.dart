import 'package:shotplay_app/src/features/ingresar_codigo/data/source/ingresar_codigo_data_source.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/domain/model/ingresar_codigo_user.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/domain/repository/ingresar_codigo_repository.dart';

class IngresarCodigoRepositoryImpl extends IngresarCodigoRepository {
  final IngresarCodigoDataSource _source = IngresarCodigoDataSource();

  @override
  Future<IngresarCodigoUser?> getIngresarCodigoUser(String userId) async {
    return _source.getIngresarCodigoUser(userId);
  }
}
