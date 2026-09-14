import 'package:ekeyless/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final usuarioActual = Supabase.instance.client.auth.currentUser;

    if (usuarioActual == null) {
      const rutasPublicas = [
        AppRoutes.login,
        AppRoutes.registro,
        AppRoutes.recuperarContrasena,
        AppRoutes.splash,
      ];
      if (!rutasPublicas.contains(route)) {
        return const RouteSettings(name: AppRoutes.login);
      }
    } else {
      const rutasNoProtegidas = [
        AppRoutes.login,
        AppRoutes.registro,
        AppRoutes.recuperarContrasena,
      ];
      if (rutasNoProtegidas.contains(route)) {
        return const RouteSettings(name: AppRoutes.candado);
      }
    }
    return null;
  }
}
