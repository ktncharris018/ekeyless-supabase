import 'package:flutter/material.dart';

class ValidatorUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  static String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final email = valor.trim();

    if (email.isEmpty) {
      return 'El correo no puede estar vacío';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }

    if (email.length > 254) {
      return 'El correo es demasiado largo';
    }

    return null;
  }

  static String? validarUsername(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa un nombre de usuario';
    }

    final username = valor.trim();

    if (username.isEmpty) {
      return 'El nombre de usuario no puede estar vacío';
    }

    if (username.length < 3) {
      return 'Debe tener al menos 3 caracteres';
    }

    if (username.length > 20) {
      return 'Máximo 20 caracteres permitidos';
    }

    if (!_usernameRegex.hasMatch(username)) {
      return 'Solo se permiten letras, números y guión bajo';
    }

    if (username.startsWith('_') || username.endsWith('_')) {
      return 'No puede empezar o terminar con guión bajo';
    }

    if (username.contains('__')) {
      return 'No se permiten guiones bajos consecutivos';
    }

    return null;
  }

  static String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (valor.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }

    if (valor.length > 12) {
      return 'Máximo 12 caracteres permitidos';
    }

    if (!_uppercaseRegex.hasMatch(valor)) {
      return 'Debe contener al menos una mayúscula';
    }

    if (!_lowercaseRegex.hasMatch(valor)) {
      return 'Debe contener al menos una minúscula';
    }

    if (!_numberRegex.hasMatch(valor)) {
      return 'Debe contener al menos un número';
    }

    if (!_specialCharRegex.hasMatch(valor)) {
      return 'Debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)';
    }

    if (valor.contains(' ')) {
      return 'No puede contener espacios';
    }

    return null;
  }

  static String? validarConfirmacionContrasena(
    String? valor,
    String? contrasenaOriginal,
  ) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (contrasenaOriginal == null || contrasenaOriginal.isEmpty) {
      return 'Primero ingresa una contraseña';
    }

    if (valor != contrasenaOriginal) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  static PasswordStrength evaluarFortalezaContrasena(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.vacia;
    }

    int puntuacion = 0;

    if (password.length >= 8) puntuacion++;
    if (password.length >= 10) puntuacion++;

    if (_uppercaseRegex.hasMatch(password)) puntuacion++;
    if (_lowercaseRegex.hasMatch(password)) puntuacion++;
    if (_numberRegex.hasMatch(password)) puntuacion++;
    if (_specialCharRegex.hasMatch(password)) puntuacion++;

    if (password.length > 8 && _getUniqueCharacterCount(password) > 6) {
      puntuacion++;
    }

    switch (puntuacion) {
      case 0:
      case 1:
      case 2:
        return PasswordStrength.debil;
      case 3:
      case 4:
        return PasswordStrength.media;
      case 5:
      case 6:
        return PasswordStrength.fuerte;
      default:
        return PasswordStrength.muyFuerte;
    }
  }

  static String getMensajeFortaleza(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.vacia:
        return '';
      case PasswordStrength.debil:
        return 'Contraseña débil';
      case PasswordStrength.media:
        return 'Contraseña media';
      case PasswordStrength.fuerte:
        return 'Contraseña fuerte';
      case PasswordStrength.muyFuerte:
        return 'Contraseña muy fuerte';
    }
  }

  static Color getColorFortaleza(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.vacia:
        return Colors.transparent;
      case PasswordStrength.debil:
        return Colors.red;
      case PasswordStrength.media:
        return Colors.orange;
      case PasswordStrength.fuerte:
        return Colors.blue;
      case PasswordStrength.muyFuerte:
        return Colors.green;
    }
  }

  static Map<String, String?> validarCamposRegistro({
    String? email,
    String? username,
    String? password,
    String? confirmPassword,
  }) {
    return {
      'email': validarEmail(email),
      'username': validarUsername(username),
      'password': validarContrasena(password),
      'confirmPassword': validarConfirmacionContrasena(
        confirmPassword,
        password,
      ),
    };
  }

  static List<String> getSugerenciasContrasena(String? password) {
    if (password == null || password.isEmpty) {
      return ['Ingresa una contraseña'];
    }

    List<String> sugerencias = [];

    if (password.length < 8) {
      sugerencias.add('Añade más caracteres (mínimo 8)');
    }

    if (!_uppercaseRegex.hasMatch(password)) {
      sugerencias.add('Incluye al menos una letra mayúscula');
    }

    if (!_lowercaseRegex.hasMatch(password)) {
      sugerencias.add('Incluye al menos una letra minúscula');
    }

    if (!_numberRegex.hasMatch(password)) {
      sugerencias.add('Incluye al menos un número');
    }

    if (!_specialCharRegex.hasMatch(password)) {
      sugerencias.add('Incluye al menos un carácter especial');
    }

    if (password.contains(' ')) {
      sugerencias.add('Elimina los espacios');
    }

    return sugerencias;
  }

  static int _getUniqueCharacterCount(String text) {
    return text.split('').toSet().length;
  }
}

enum PasswordStrength { vacia, debil, media, fuerte, muyFuerte }

extension PasswordStrengthExtension on PasswordStrength {
  double get progress {
    switch (this) {
      case PasswordStrength.vacia:
        return 0.0;
      case PasswordStrength.debil:
        return 0.25;
      case PasswordStrength.media:
        return 0.5;
      case PasswordStrength.fuerte:
        return 0.75;
      case PasswordStrength.muyFuerte:
        return 1.0;
    }
  }

  bool get esValida {
    return this != PasswordStrength.vacia && this != PasswordStrength.debil;
  }
}
