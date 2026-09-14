import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _verificarEstadoAutenticacion();
  }

  Future<void> _verificarEstadoAutenticacion() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final uri = Uri.base;

      // Recuperación de contraseña
      if (uri.queryParameters['recovery'] == '1') {
        Get.offAllNamed(AppRoutes.cambiarContrasena);
        return;
      }

      // Comprobar si existe una sesión activa
      final autologinExitoso = await _authService.intentarAutologin();

      if (autologinExitoso && _authService.hayUsuarioActivo) {
        // Sincronizar el perfil si corresponde
        await _authService.sincronizarPerfilGoogle();

        Get.offAllNamed(AppRoutes.candado);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
