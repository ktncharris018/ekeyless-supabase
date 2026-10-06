import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/routes/app_routes.dart';
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
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text(
                  'Perfiles de acceso reutilizables',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Guarda y reutiliza configuraciones de acceso para este candado.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(
                  AppRoutes.perfilesAcceso,
                  arguments: controller.candado,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
