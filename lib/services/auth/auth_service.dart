import 'package:ekeyless/configs/supabase_config.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/repositories/usuario_repository.dart';
import 'package:ekeyless/repositories/storage_repository.dart';
import 'package:ekeyless/strategies/email_password_auth_strategy.dart';
import 'package:ekeyless/strategies/google_auth_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    SupabaseClient? client,
    UsuarioRepository? usuarios,
    ImageStorageRepository? storage,
  }) : _client = client ?? Supabase.instance.client,
       _usuarios =
           usuarios ??
           SupabaseUsuarioRepository(
             client: client ?? Supabase.instance.client,
           ),
       _storage =
           storage ??
           SupabaseImageStorageAdapter(
             client: client ?? Supabase.instance.client,
           );

  final SupabaseClient _client;
  final UsuarioRepository _usuarios;
  final ImageStorageRepository _storage;

  ImageStorageRepository get imageStorage => _storage;

  // ============================================================
  // VERIFICAR EMAIL
  // ============================================================

  Future<bool> verificarEmailDisponible(String email) {
    return _usuarios.emailDisponible(email);
  }

  // ============================================================
  // VERIFICAR NOMBRE DE USUARIO
  // ============================================================

  Future<bool> verificarNombreUsuarioDisponible(String nombreUsuario) {
    return _usuarios.nombreUsuarioDisponible(nombreUsuario);
  }

  // ============================================================
  // OBTENER USUARIO POR EMAIL
  // ============================================================

  Future<UsuarioModel?> obtenerDatosUsuario(String email) {
    return _usuarios.obtenerPorEmail(email);
  }

  // ============================================================
  // OBTENER USUARIO ACTUAL
  // ============================================================

  Future<UsuarioModel?> obtenerDatosUsuarioActual() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return _usuarios.obtenerPorId(user.id);
  }

  // ============================================================
  // REGISTRAR USUARIO
  //
  // IMPORTANTE:
  // - No usamos emailRedirectTo porque por ahora
  //   Confirm email estará desactivado en Supabase.
  // - Supabase Auth crea primero al usuario.
  // - Luego creamos su perfil en public.usuarios.
  // ============================================================

  Future<void> registrarUsuario(UsuarioModel usuario, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: usuario.email,
        password: password,
        data: {
          'nombreUsuario': usuario.nombreUsuario,
          'authGoogle': false,
          'imagenPerfil': usuario.imagenPerfil,
        },
      );

      final user = response.user;

      if (user == null) {
        throw const AuthServiceException(
          'registration-failed',
          'No se pudo crear el usuario.',
        );
      }

      final perfil = usuario.copyWith(id: user.id, authGoogle: false);

      await _usuarios.crear(perfil);

      // Como Confirm email está desactivado,
      // normalmente habrá una sesión inmediatamente.
      //
      // Si algún día vuelves a activar Confirm email,
      // este bloque permitirá detectar ese escenario.
      if (response.session == null) {
        throw const AuthServiceException(
          'email-confirmation-required',
          'El correo requiere confirmación antes de iniciar sesión.',
        );
      }
    } on AuthServiceException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthServiceException(
        'registration-error',
        'No se pudo completar el registro: $e',
      );
    }
  }

  // ============================================================
  // INICIAR SESIÓN CON EMAIL Y CONTRASEÑA
  //
  // IMPORTANTE:
  // NO consultamos public.usuarios para comprobar si
  // existe el email antes del login.
  //
  // Primero autenticamos contra Supabase Auth.
  // Después obtenemos el perfil de public.usuarios.
  // ============================================================

  Future<void> iniciarSesion(String email, String contrasena) async {
    try {
      await EmailPasswordAuthStrategy(
        client: _client,
        email: email,
        password: contrasena,
      ).execute();

      final user = _client.auth.currentUser;

      if (user == null) {
        throw const AuthServiceException(
          'no-session',
          'No se pudo obtener la sesión del usuario.',
        );
      }

      // Ya estamos autenticados, por lo que RLS permite
      // consultar el perfil correspondiente.
      final perfil = await _usuarios.obtenerPorId(user.id);

      // Si el usuario no tiene perfil, no bloqueamos el login
      // por este motivo. La cuenta de Auth sí existe.
      if (perfil == null) {
        return;
      }

      // Si fue registrado con Google, debe iniciar sesión
      // mediante Google.
      if (perfil.authGoogle) {
        await _client.auth.signOut(scope: SignOutScope.local);

        throw const AuthServiceException(
          'wrong-provider',
          'Este correo está asociado a Google Sign-In. Use "Iniciar con Google".',
        );
      }
    } on AuthServiceException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthServiceException(
        'login-error',
        'No se pudo iniciar sesión: $e',
      );
    }
  }

  // ============================================================
  // INICIAR SESIÓN CON GOOGLE
  // ============================================================

  Future<void> iniciarSesionConGoogle() async {
    try {
      // Limpiar una posible sesión local anterior.
      await _client.auth.signOut(scope: SignOutScope.local);

      // Iniciar OAuth mediante Strategy Pattern.
      await GoogleAuthStrategy(client: _client).execute();

      final user = _client.auth.currentUser;

      if (user == null) {
        throw const AuthServiceException(
          'no-session',
          'No se obtuvo una sesión de Google.',
        );
      }

      final email = user.email ?? '';

      // Como ya estamos autenticados podemos consultar
      // public.usuarios sin el problema de RLS anterior.
      final existente = await _usuarios.obtenerPorId(user.id);

      // Si ya existe y originalmente fue registrado
      // mediante email/password, no permitimos mezclar
      // proveedores para la misma cuenta.
      if (existente != null && !existente.authGoogle) {
        await _client.auth.signOut(scope: SignOutScope.local);

        throw const AuthServiceException(
          'wrong-provider',
          'Este correo está registrado con email/contraseña. Use ese método.',
        );
      }

      // Si no existe el perfil, lo creamos.
      if (existente == null) {
        final metadata = user.userMetadata ?? {};

        final imagenPerfil =
            metadata['avatar_url']?.toString() ??
            metadata['picture']?.toString() ??
            '';

        final nombreUsuario =
            metadata['full_name']?.toString() ??
            metadata['name']?.toString() ??
            (email.isNotEmpty ? email.split('@').first : 'usuario');

        await _usuarios.crear(
          UsuarioModel(
            id: user.id,
            imagenPerfil: imagenPerfil,
            nombreUsuario: nombreUsuario,
            email: email,
            authGoogle: true,
          ),
        );
      }
    } on AuthServiceException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthServiceException(
        'google-login-error',
        'No se pudo iniciar sesión con Google: $e',
      );
    }
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================

  Future<void> recuperarContrasena(String email) async {
    try {
      final redirectUrl = '${Uri.base.origin}/?recovery=1';

      await _client.auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthServiceException(
        'password-reset-error',
        'No se pudo solicitar la recuperación de contraseña: $e',
      );
    }
  }

  Future<void> cambiarContrasena(String nuevaContrasena) async {
    try {
      if (_client.auth.currentSession == null) {
        throw const AuthServiceException(
          'no-session',
          'La sesión de recuperación no es válida o ha expirado.',
        );
      }

      await _client.auth.updateUser(UserAttributes(password: nuevaContrasena));
    } on AuthServiceException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthServiceException(
        'password-update-error',
        'No se pudo actualizar la contraseña: $e',
      );
    }
  }

  Future<void> sincronizarPerfilGoogle() async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    final esGoogle =
        user.appMetadata['provider']?.toString().toLowerCase() == 'google' ||
        (user.identities?.any(
              (identity) => identity.provider.toLowerCase() == 'google',
            ) ??
            false);

    if (!esGoogle) return;

    final existente = await _usuarios.obtenerPorId(user.id);

    if (existente != null) {
      return;
    }

    final metadata = user.userMetadata ?? {};
    final email = user.email ?? '';

    final imagenPerfil =
        metadata['avatar_url']?.toString() ??
        metadata['picture']?.toString() ??
        '';

    final nombreUsuario =
        metadata['full_name']?.toString() ??
        metadata['name']?.toString() ??
        (email.isNotEmpty ? email.split('@').first : 'usuario');

    await _usuarios.crear(
      UsuarioModel(
        id: user.id,
        imagenPerfil: imagenPerfil,
        nombreUsuario: nombreUsuario,
        email: email,
        authGoogle: true,
      ),
    );
  }

  // ============================================================
  // ACTUALIZAR IMAGEN DE PERFIL
  // ============================================================

  Future<void> actualizarImagenPerfil(String imageUrl) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw const AuthServiceException('no-session', 'Usuario no autenticado.');
    }

    final perfil = await _usuarios.obtenerPorId(user.id);

    if (perfil == null) {
      return;
    }

    await _usuarios.actualizar(perfil.copyWith(imagenPerfil: imageUrl));
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> cerrarSesion() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ============================================================
  // AUTOLOGIN
  // ============================================================

  Future<bool> intentarAutologin() async {
    return _client.auth.currentSession != null;
  }

  // ============================================================
  // ESTADO ACTUAL
  // ============================================================

  bool get hayUsuarioActivo => _client.auth.currentUser != null;

  User? get usuarioActual => _client.auth.currentUser;

  // ============================================================
  // MAPEAR ERRORES DE SUPABASE AUTH
  // ============================================================

  AuthServiceException _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();

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

    if (message.contains('already registered')) {
      return const AuthServiceException(
        'email-already-in-use',
        'Este correo ya está registrado.',
      );
    }

    if (message.contains('user already registered')) {
      return const AuthServiceException(
        'email-already-in-use',
        'Este correo ya está registrado.',
      );
    }

    final code = e.code;

    if (code != null && code.isNotEmpty) {
      return AuthServiceException(code, e.message);
    }

    return AuthServiceException('auth-error', e.message);
  }
}
