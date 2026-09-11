import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _verificarEstadoAutenticacion();
  }

  Future<void> _verificarEstadoAutenticacion() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final uri = Uri.base;

      if (uri.queryParameters['recovery'] == '1') {
        Get.offAllNamed(AppRoutes.cambiarContrasena);
        return;
      }

      final autologinExitoso = await _authService.intentarAutologin();

      if (autologinExitoso && _authService.hayUsuarioActivo) {
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
