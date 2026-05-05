import 'package:shotplay_app/src/features/enter_code/data/source/enter_code_data_source.dart';
import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';
import 'package:shotplay_app/src/features/enter_code/domain/repository/enter_code_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnterCodeRepositoryImpl extends EnterCodeRepository {
  final EnterCodeDataSource _source = EnterCodeDataSource();

  @override
  Future<EnterCodeUser?> getEnterCodeUser(String userId) async {
    final user = await _source.getEnterCodeUser(userId);
    if (user != null) return user;

    // Fallback: build from auth session when the profiles row doesn't
    // exist yet (e.g. right after signup before the DB write).
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return null;

    final fromMeta = authUser.userMetadata?['username'] as String?;
    final fromEmail = authUser.email?.split('@').first;
    final resolved = (fromMeta != null && fromMeta.isNotEmpty)
        ? fromMeta
        : (fromEmail ?? 'Usuario');
    return EnterCodeUser(username: resolved);
  }
}
