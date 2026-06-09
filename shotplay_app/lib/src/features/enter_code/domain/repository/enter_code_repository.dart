import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';

abstract class EnterCodeRepository {
  Future<EnterCodeUser?> getEnterCodeUser(String userId);
}
