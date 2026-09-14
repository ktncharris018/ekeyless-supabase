import 'package:ekeyless/controllers/auth/splash_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorUtils.applyOpacity(AppColors.primary, 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset('assets/logo.png', width: 64, height: 64),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'e-KeyLess',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Tu teléfono es la única llave que necesitas',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Indicador de carga
            const CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
