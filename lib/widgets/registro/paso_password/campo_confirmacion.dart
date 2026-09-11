import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampoConfirmacion extends StatelessWidget {
  final RegistroController controller;
  final VoidCallback onSubmit;

  const CampoConfirmacion({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller.confirmPasswordCtrl,
        obscureText: !controller.mostrarConfirmacion.value,
        decoration: InputDecoration(
          labelText: 'Confirmar contraseña',
          hintText: 'Repite tu contraseña',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              controller.mostrarConfirmacion.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: controller.alternarVisibilidadConfirmacion,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        validator: controller.validarConfirmacion,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => onSubmit(),
      ),
    );
  }
}
