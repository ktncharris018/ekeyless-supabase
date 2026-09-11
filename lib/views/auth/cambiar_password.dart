import 'package:ekeyless/controllers/auth/cambiarpassword_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CambiarPasswordPage extends StatelessWidget {
  const CambiarPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CambiarPasswordController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorUtils.applyOpacity(
                              AppColors.primary,
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Nueva contraseña',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Ingresa una nueva contraseña para recuperar el acceso a tu cuenta.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordCtrl,
                            obscureText: !controller.mostrarContrasena.value,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.mostrarContrasena.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.alternarContrasena,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: controller.validarContrasena,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(
                          () => TextFormField(
                            controller: controller.confirmPasswordCtrl,
                            obscureText: !controller.mostrarConfirmacion.value,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              controller.cambiarContrasena();
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.mostrarConfirmacion.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.alternarConfirmacion,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: controller.validarConfirmacion,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'La contraseña debe cumplir:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• Entre 8 y 12 caracteres\n'
                            '• Al menos una mayúscula\n'
                            '• Al menos una minúscula\n'
                            '• Al menos un número\n'
                            '• Al menos un carácter especial\n'
                            '• Sin espacios',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.cargando.value
                                ? null
                                : controller.cambiarContrasena,
                        child:
                            controller.cargando.value
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Cambiar contraseña'),
                      ),
                    ),
                  ),

                  Center(
                    child: TextButton(
                      onPressed: controller.volverAlLogin,
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
