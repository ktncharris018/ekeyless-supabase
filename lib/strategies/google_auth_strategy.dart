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
    // ------------------------------------------------------------
    // WEB
    //
    // En navegador, signInWithOAuth redirige la página hacia Google.
    // Al regresar, Flutter Web vuelve a arrancar y SplashController
    // detectará la sesión existente.
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // ANDROID / IOS
    //
    // En móvil mantenemos el flujo mediante deep link.
    // ------------------------------------------------------------
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

      // Es posible que la sesión ya exista cuando el callback
      // termine inmediatamente.
      if (_client.auth.currentSession != null && !completer.isCompleted) {
        completer.complete();
      }

      await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout:
            () =>
                throw const AuthException(
                  'El inicio de sesión con Google tardó demasiado o fue cancelado.',
                ),
      );
    } finally {
      await subscription.cancel();
    }
  }
}
