import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/widgets/registro/paso_email.dart';
import 'package:ekeyless/widgets/registro/paso_perfil/paso_perfil.dart';
import 'package:ekeyless/widgets/registro/paso_password/paso_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistroController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: controller.volverPasoAnterior),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          switch (controller.pasoActual.value) {
            case 0:
              return PasoEmail(controller: controller, theme: theme);
            case 1:
              return PasoPerfil(controller: controller, theme: theme);
            case 2:
              return PasoPassword(controller: controller, theme: theme);
            default:
              return PasoEmail(controller: controller, theme: theme);
          }
        }),
      ),
    );
  }
}
