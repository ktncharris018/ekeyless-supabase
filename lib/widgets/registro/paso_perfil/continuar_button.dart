import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';

class ContinuarButton extends StatelessWidget {
  final RegistroController controller;

  const ContinuarButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() {
        final cargando = controller.cargando.value;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: cargando ? null : controller.avanzarAContrasena,
          child:
              cargando
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Continuar'),
        );
      }),
    );
  }
}
