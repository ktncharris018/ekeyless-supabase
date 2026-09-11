import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/widgets/candado/boton_compartir.dart';
import 'package:ekeyless/widgets/candado/configuracion_temporal.dart';
import 'package:ekeyless/widgets/candado/selector_acceso.dart';
import 'package:ekeyless/widgets/candado/selector_amigo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeccionCompartirAcceso extends StatelessWidget {
  final CompartirAccesoController controller;

  const SeccionCompartirAcceso({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compartir nuevo acceso',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de amigo
              SelectorAmigo(controller: controller),

              const SizedBox(height: 24),

              // Selector de tipo de acceso
              SelectorTipoAcceso(controller: controller),

              const SizedBox(height: 24),

              // Configuración temporal (si aplica)
              Obx(
                () => ConfiguracionTemporal(
                  controller: controller,
                  visible: controller.esTemporal.value,
                ),
              ),

              const SizedBox(height: 24),

              // Botón compartir
              BotonCompartir(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}