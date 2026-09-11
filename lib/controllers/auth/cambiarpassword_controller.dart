import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:ekeyless/utils/alertas.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:ekeyless/utils/validator_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CambiarPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final RxBool mostrarContrasena = false.obs;
  final RxBool mostrarConfirmacion = false.obs;
  final RxBool cargando = false.obs;

  final AuthService _authService = AuthService();

  @override
  void onClose() {
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  String? validarContrasena(String? valor) {
    return ValidatorUtils.validarContrasena(valor);
  }

  String? validarConfirmacion(String? valor) {
    return ValidatorUtils.validarConfirmacionContrasena(
      valor,
      passwordCtrl.text,
    );
  }

  void alternarContrasena() {
    mostrarContrasena.value = !mostrarContrasena.value;
  }

  void alternarConfirmacion() {
    mostrarConfirmacion.value = !mostrarConfirmacion.value;
  }

  Future<void> cambiarContrasena() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    cargando.value = true;

    try {
      await _authService.cambiarContrasena(passwordCtrl.text);

      Get.snackbar(
        'Contraseña actualizada',
        'La contraseña se cambió correctamente.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ColorUtils.applyOpacity(Colors.green, 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      await Future.delayed(const Duration(seconds: 2));

      await _authService.cerrarSesion();

      Get.offAllNamed(AppRoutes.login);
    } on AuthServiceException catch (e) {
      Alerta.mostrarError(e.message);
    } catch (e) {
      Alerta.mostrarError('No se pudo cambiar la contraseña');
    } finally {
      cargando.value = false;
    }
  }

  void volverAlLogin() {
    Get.offAllNamed(AppRoutes.login);
  }
}
