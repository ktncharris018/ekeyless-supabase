import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfiguracionController extends GetxController {
  static String name = 'Vista de Configuración';
  final AuthService authService = AuthService();

  String nombre() => name;

  void mostrarDialogoSalir(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion();
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion() async {
    try {
      await authService.cerrarSesion();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cerrar la sesión. Inténtalo de nuevo.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
