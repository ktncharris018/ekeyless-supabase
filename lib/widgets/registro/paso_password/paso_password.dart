import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:ekeyless/utils/validator_util.dart';
import 'package:ekeyless/widgets/registro/indicador.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'boton_registro.dart';
import 'campo_confirmacion.dart';
import 'campo_password.dart';
import 'indicador_coincidencia.dart';
import 'indicador_fortaleza.dart';
import 'informacion_politica.dart';
import 'sugerencias_password.dart';

class PasoPassword extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const PasoPassword({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepIndicator(currentStep: 3, totalSteps: 3),
          const SizedBox(height: 24),

          Text(
            'Crea una contraseña segura',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu contraseña debe ser segura para proteger tu cuenta',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          Form(
            key: controller.formKeyPassword,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampoPassword(controller: controller),
                const SizedBox(height: 12),

                IndicadorFortaleza(controller: controller, theme: theme),

                SugerenciasPassword(controller: controller, theme: theme),

                const SizedBox(height: 16),

                CampoConfirmacion(
                  controller: controller,
                  onSubmit: _intentarRegistro,
                ),

                IndicadorCoincidencia(controller: controller, theme: theme),

                const SizedBox(height: 24),

                InformacionPolitica(theme: theme),
              ],
            ),
          ),
          const SizedBox(height: 32),

          BotonRegistro(controller: controller, onPressed: _intentarRegistro),
        ],
      ),
    );
  }

  void _intentarRegistro() {
    final fortaleza = controller.fortalezaContrasena.value;
    if (!fortaleza.esValida) {
      Get.snackbar(
        'Contraseña insegura',
        'Por favor, crea una contraseña más segura siguiendo las sugerencias',
        snackPosition: SnackPosition.TOP,
        backgroundColor: ColorUtils.applyOpacity(Colors.orange, 0.1),
        colorText: Colors.orange[800],
        icon: const Icon(Icons.warning, color: Colors.orange),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    controller.registrarUsuario();
  }
}
