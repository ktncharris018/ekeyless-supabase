import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/widgets/registro/indicador.dart';
import 'package:flutter/material.dart';

import 'avatar_selector.dart';
import 'continuar_button.dart';
import 'nombre_usuario_field.dart';
import 'opciones_foto_bottom_sheet.dart';

class PasoPerfil extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const PasoPerfil({super.key, required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepIndicator(currentStep: 2, totalSteps: 3),
          const SizedBox(height: 24),
          Text(
            'Personaliza tu perfil',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade una foto de perfil y elige un nombre de usuario',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          AvatarSelector(
            controller: controller,
            onTap: () => mostrarOpcionesFoto(context),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Toca para añadir una foto',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          NombreUsuarioField(controller: controller),
          const SizedBox(height: 32),
          ContinuarButton(controller: controller),
        ],
      ),
    );
  }

  void mostrarOpcionesFoto(BuildContext context) {
    OpcionesFotoBottomSheet.mostrar(context, theme, controller);
  }
}
