class RegistroValidator {
  static String? validarNombreUsuario(String? nombre) {
    if (nombre == null || nombre.isEmpty) return 'Campo requerido';
    if (nombre.length < 3) return 'Mínimo 3 caracteres';
    if (nombre.length > 20) return 'Máximo 20 caracteres';
    return null;
  }

  static String? validarCorreo(String? correo) {
    if (correo == null || correo.isEmpty) return 'Campo requerido';
    final regex = RegExp(r'^[^@\s]+@[^@\s]*m[^@\s]*\.(com|net|org|edu)$');
    if (!regex.hasMatch(correo)) return 'Correo no válido';
    return null;
  }

  static String? validarContrasena(String? pass) {
    if (pass == null || pass.isEmpty) return 'Campo requerido';
    if (pass.length < 8) return 'Mínimo 8 caracteres';
    if (pass.length > 12) return 'Máximo 12 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(pass)) return 'Debe contener mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(pass)) return 'Debe contener minúscula';
    if (!RegExp(r'[0-9]').hasMatch(pass)) return 'Debe contener número';
    if (!RegExp(r'[!@#\\\$%^&*~]').hasMatch(pass)) return 'Debe contener carácter especial';
    if (pass.contains(' ')) return 'No debe contener espacios';
    return null;
  }

  static String? validarConfirmarContrasena(String? pass, String? confirm) {
    if (confirm == null || confirm.isEmpty) return 'Campo requerido';
    if (pass != confirm) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? validarImagen(String? path) {
    if (path == null || path.isEmpty) return null; 
    final esURL = path.startsWith('http');
    final esAsset = path.startsWith('assets/');
    if (!esURL && !esAsset) return 'Formato de imagen no válido';
    return null;
  }
}
