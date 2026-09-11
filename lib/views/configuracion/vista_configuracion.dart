import 'package:ekeyless/widgets/estructura/bottom_nav_bar.dart';
import 'package:ekeyless/widgets/estructura/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/configuracion/configuracion_controller.dart';

class VistaConfiguracion extends StatelessWidget {
  const VistaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfiguracionController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Configuración'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.nombre(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: () => controller.mostrarDialogoSalir(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
