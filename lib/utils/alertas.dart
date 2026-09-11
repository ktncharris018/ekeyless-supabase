import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Alerta {
  static void mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorUtils.applyOpacity(Colors.red, 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  static void mostrarAviso(String mensaje) {
    Get.snackbar(
      'Aviso',
      mensaje,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorUtils.applyOpacity(Colors.orange, 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void mostrarExito(String mensaje) {
    Get.snackbar(
      'Éxito',
      mensaje,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorUtils.applyOpacity(Colors.green, 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
