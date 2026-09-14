import 'package:flutter/material.dart';
import 'package:ekeyless/controllers/auth/registro_controller.dart';

class NombreUsuarioField extends StatelessWidget {
  final RegistroController controller;

  const NombreUsuarioField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKeyProfile,
      child: TextFormField(
        controller: controller.usernameCtrl,
        decoration: const InputDecoration(
          labelText: 'Nombre de usuario',
          hintText: 'Tu nombre de usuario',
          prefixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        validator: controller.validarUsername,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => controller.avanzarAContrasena(),
      ),
    );
  }
}
