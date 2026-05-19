import 'package:supabase_flutter/supabase_flutter.dart';

String? safeCurrentUserId() {
  try {
    return Supabase.instance.client.auth.currentUser?.id;
  } catch (_) {
    return null;
  }
}

bool isSupabaseReady() {
  try {
    Supabase.instance.client;
    return true;
  } catch (_) {
    return false;
  }
}