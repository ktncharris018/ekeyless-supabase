import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:ekeyless/services/auth/auth_service_exception.dart';
import 'package:ekeyless/utils/alertas.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecuperarPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final RxBool cargando = false.obs;
  final AuthService _authService = AuthService();

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }

  String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) return 'Ingresa tu correo';
    if (!GetUtils.isEmail(valor.trim())) return 'Correo inválido';
    return null;
  }

  Future<void> enviarEmailRecuperacion() async {
    if (!formKey.currentState!.validate()) return;

    cargando.value = true;
    try {
      await _authService.recuperarContrasena(emailCtrl.text.trim());

      Get.snackbar(
        'Email enviado',
        'Se ha enviado un enlace de recuperación a tu correo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ColorUtils.applyOpacity(Colors.green, 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      String mensaje = 'Error al enviar email de recuperación';

      if (e is AuthServiceException) {
        switch (e.code) {
          case 'user-not-found':
            mensaje = 'Email no registrado en la aplicación';
            break;
          case 'wrong-provider':
            mensaje =
                'Este correo está registrado con Google. No puede recuperar contraseña desde aquí. Inicie sesión con Google directamente.';
            break;
          case 'invalid-email':
            mensaje = 'Formato de email inválido';
            break;
          case 'too-many-requests':
            mensaje =
                'Demasiados intentos. Espere antes de intentar nuevamente';
            break;
        }
      }

      Alerta.mostrarError(mensaje);
    } finally {
      cargando.value = false;
    }
  }

  void volverAlLogin() {
    Get.back();
  }
}
