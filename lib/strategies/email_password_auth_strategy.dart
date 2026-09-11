import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_strategy.dart';

class EmailPasswordAuthStrategy implements AuthStrategy {
  EmailPasswordAuthStrategy({
    required SupabaseClient client,
    required String email,
    required String password,
  })  : _client = client,
        _email = email,
        _password = password;

  final SupabaseClient _client;
  final String _email;
  final String _password;

  @override
  Future<void> execute() async {
    await _client.auth.signInWithPassword(
      email: _email,
      password: _password,
    );
  }
}
