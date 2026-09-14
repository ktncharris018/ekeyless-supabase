import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:ekeyless/services/auth/auth_service_exception.dart';
import 'package:ekeyless/utils/alertas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController({AuthService? authService}) : authService = authService ?? AuthService();

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final RxBool mostrarContrasena = false.obs;
  final RxBool cargando = false.obs;

  final AuthService authService;

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }

  Future<void> iniciarSesion() async {
    if (!formKey.currentState!.validate()) return;

    try {
      cargando.value = true;
      await authService.iniciarSesion(emailCtrl.text.trim(), passCtrl.text);
      Get.offAllNamed(AppRoutes.candado);
    } catch (e) {
      String mensaje = 'Error al iniciar sesión';

      if (e is AuthServiceException) {
        switch (e.code) {
          case 'user-not-found':
            mensaje = 'Email no registrado';
            break;
          case 'wrong-password':
            mensaje = 'Contraseña incorrecta';
            break;
          case 'wrong-provider':
            mensaje =
                'Este correo está asociado a Google Sign-In. Use "Iniciar con Google"';
            break;
          case 'invalid-email':
            mensaje = 'Formato de email inválido';
            break;
          case 'user-disabled':
            mensaje = 'Usuario deshabilitado';
            break;
          case 'too-many-requests':
            mensaje = 'Demasiados intentos fallidos. Intente más tarde';
            break;
          case 'invalid-credential':
            mensaje = 'Credenciales inválidas. Verifique email y contraseña';
            break;
        }
      }

      Alerta.mostrarError(mensaje);
    } finally {
      cargando.value = false;
    }
  }

  Future<void> iniciarSesionConGoogle() async {
    try {
      cargando.value = true;
      await authService.iniciarSesionConGoogle();
      Get.offAllNamed(AppRoutes.candado);
    } catch (e) {
      String mensaje = 'Error al iniciar sesión con Google';

      if (e is AuthServiceException) {
        switch (e.code) {
          case 'wrong-provider':
            mensaje =
                'Este correo está registrado con email/contraseña. Use ese método';
            break;
          case 'network-request-failed':
            mensaje = 'Error de conexión. Verifique su internet';
            break;
          case 'account-exists-with-different-credential':
            mensaje = 'Esta cuenta ya existe con otro método de autenticación';
            break;
        }
      } else if (e.toString().contains('ERROR_CANCELED_BY_USER') ||
          e.toString().contains('sign_in_canceled')) {
        // Usuario canceló el login, no mostrar error
        return;
      }

      Alerta.mostrarError(mensaje);
    } finally {
      cargando.value = false;
    }
  }

  void alternarVisibilidadContrasena() {
    mostrarContrasena.value = !mostrarContrasena.value;
  }

  String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu correo';
    }
    if (!GetUtils.isEmail(valor.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void irARegistro() {
    Get.toNamed(AppRoutes.registro);
  }

  void recuperarContrasena() {
    Get.toNamed(AppRoutes.recuperarContrasena);
  }
}
