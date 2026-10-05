import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service_exception.dart';

class AuthExceptionMapper {
  AuthServiceException mapear(AuthException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return const AuthServiceException(
        'invalid-credential',
        'Credenciales inválidas. Verifique el email y la contraseña.',
      );
    }

    if (message.contains('email not confirmed')) {
      return const AuthServiceException(
        'email-not-confirmed',
        'Debes confirmar tu correo antes de iniciar sesión.',
      );
    }

    if (message.contains('already registered') ||
        message.contains('user already registered')) {
      return const AuthServiceException(
        'email-already-in-use',
        'Este correo ya está registrado.',
      );
    }

    final code = exception.code;
    if (code != null && code.isNotEmpty) {
      return AuthServiceException(code, exception.message);
    }

    return AuthServiceException('auth-error', exception.message);
  }
}
