import 'package:ekeyless/validators/registro_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validación nombre de usuario', () {
    test('Nombre válido (3 caracteres) - Valor límite inferior - Clase válida', () {
      expect(RegistroValidator.validarNombreUsuario('abc'), null);
    });
    test('Nombre muy corto (2 caracteres) - Clase inválida', () {
      expect(RegistroValidator.validarNombreUsuario('ab'), isNotNull);
    });
    test('Nombre muy largo (21 caracteres) - Clase inválida', () {
      expect(RegistroValidator.validarNombreUsuario('abcdefghijklmnopqrstu'), isNotNull);
    });
  });

  group('Validación correo', () {
    test('Correo válido "a@m.com" - Clase válida', () {
      expect(RegistroValidator.validarCorreo('a@m.com'), null);
    });
    test('Correo sin @ - Clase inválida', () {
      expect(RegistroValidator.validarCorreo('am.com'), isNotNull);
    });
    test('Correo sin .com - Clase inválida', () {
      expect(RegistroValidator.validarCorreo('a@mcom'), isNotNull);
    });
  });

  group('Validación contraseña', () {
    test('Contraseña válida (8 caracteres) - Valor límite inferior - Clase válida', () {
      expect(RegistroValidator.validarContrasena('Abc123!@'), null);
    });
    test('Contraseña sin mayúscula - Clase inválida', () {
      expect(RegistroValidator.validarContrasena('abc123!@'), isNotNull);
    });
    test('Contraseña con espacio - Clase inválida', () {
      expect(RegistroValidator.validarContrasena('Abc 123!'), isNotNull);
    });
    test('Contraseña muy larga (13 caracteres) - Valor fuera de límite superior - Clase inválida', () {
      expect(RegistroValidator.validarContrasena('Abc123!@45678'), isNotNull);
    });
  });

  group('Validación confirmar contraseña', () {
    test('Coinciden - Clase válida', () {
      expect(RegistroValidator.validarConfirmarContrasena('Abc123!@', 'Abc123!@'), null);
    });
    test('No coinciden - Clase inválida', () {
      expect(RegistroValidator.validarConfirmarContrasena('Abc123!@', 'abc123!@'), isNotNull);
    });
  });

  group('Validación imagen', () {
    test('Imagen asset válida (assets/avatar.png) - Clase válida', () {
      expect(RegistroValidator.validarImagen('assets/avatar.png'), null);
    });
    test('Imagen null (se usa imagen por defecto) - Valor límite - Clase válida', () {
      expect(RegistroValidator.validarImagen(null), null);
    });
    test('Ruta no válida (%%% no es asset ni URL) - Clase inválida', () {
      expect(RegistroValidator.validarImagen('%%%'), isNotNull);
    });
  });
}


bool registrarUsuario({
  required String username,
  required String email,
  required String password,
  required String confirmPassword,
  required String imageUrl,
}) {
  final errorUsername = RegistroValidator.validarNombreUsuario(username);
  final errorEmail = RegistroValidator.validarCorreo(email);
  final errorPassword = RegistroValidator.validarContrasena(password);
  final errorConfirmPassword = RegistroValidator.validarConfirmarContrasena(password, confirmPassword);
  final errorImage = RegistroValidator.validarImagen(imageUrl);

  if (errorUsername != null) return false;
  if (errorEmail != null) return false;
  if (errorPassword != null) return false;
  if (errorConfirmPassword != null) return false;
  if (errorImage != null) return false;

  return true; 
}


