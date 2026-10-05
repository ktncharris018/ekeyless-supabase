import 'dart:async';

import 'package:ekeyless/configs/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_strategy.dart';

class GoogleAuthStrategy implements AuthStrategy {
  GoogleAuthStrategy({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<void> execute() async {
    if (kIsWeb) {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
      );

      if (!launched) {
        throw const AuthException('No se pudo iniciar el acceso con Google.');
      }

      return;
    }

    final completer = Completer<void>();
    late final StreamSubscription<AuthState> subscription;

    subscription = _client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.mobileRedirectUrl,
      );

      if (!launched) {
        throw const AuthException('No se pudo iniciar el acceso con Google.');
      }

      if (_client.auth.currentSession != null && !completer.isCompleted) {
        completer.complete();
      }

      await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () =>
            throw const AuthException(
              'El inicio de sesión con Google tardó demasiado o fue cancelado.',
            ),
      );
    } finally {
      await subscription.cancel();
    }
  }
}
