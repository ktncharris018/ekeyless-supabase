import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/widgets/candado/seccion_compartir_acceso.dart';
import 'package:ekeyless/widgets/candado/seccion_lista_usuarios_acceso.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VistaCompartirAcceso extends StatelessWidget {
  const VistaCompartirAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompartirAccesoController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Compartir: ${controller.candado.nombre}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black12),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeccionUsuariosConAcceso(controller: controller),
            const SizedBox(height: 32),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            SeccionCompartirAcceso(controller: controller),
          ],
        ),
      ),
    );
  }
}
