import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/widgets/registro/indicador.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasoEmail extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const PasoEmail({super.key, required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepIndicator(currentStep: 1, totalSteps: 3),
          const SizedBox(height: 24),

          Text(
            'Comencemos con tu correo',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu correo electrónico para verificar si está disponible',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          Form(
            key: controller.formKeyEmail,
            child: TextFormField(
              controller: controller.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: controller.validarEmail,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => controller.verificarEmailDisponible(),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    controller.cargando.value
                        ? null
                        : controller.verificarEmailDisponible,
                child:
                    controller.cargando.value
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Continuar'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Ya tienes una cuenta?', style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: controller.irALogin,
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
