import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BotonRegistro extends StatelessWidget {
  final RegistroController controller;
  final VoidCallback onPressed;

  const BotonRegistro({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          onPressed: controller.cargando.value ? null : onPressed,
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
                  : const Text('Completar registro'),
        ),
      ),
    );
  }
}
