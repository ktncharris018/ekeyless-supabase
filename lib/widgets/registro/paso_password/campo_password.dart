import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampoPassword extends StatelessWidget {
  final RegistroController controller;

  const CampoPassword({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordCtrl,
        obscureText: !controller.mostrarContrasena.value,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          hintText: '8-12 caracteres',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              controller.mostrarContrasena.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: controller.alternarVisibilidadContrasena,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        validator: controller.validarContrasena,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
