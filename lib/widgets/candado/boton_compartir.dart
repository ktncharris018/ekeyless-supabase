import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BotonCompartir extends StatelessWidget {
  final CompartirAccesoController controller;

  const BotonCompartir({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final puedeCompartir = _puedeCompartir();

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed:
              puedeCompartir && !controller.cargando.value
                  ? controller.compartirAcceso
                  : null,
          icon:
              controller.cargando.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.share),
          label: Text(
            controller.cargando.value ? 'Compartiendo...' : 'Compartir Acceso',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: puedeCompartir ? Colors.blue : Colors.grey[400],
            foregroundColor: Colors.white,
            elevation: puedeCompartir ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    });
  }

  bool _puedeCompartir() {
    // Verificar que hay un amigo seleccionado
    if (controller.amigoSeleccionado.value == null) {
      return false;
    }

    // Si es temporal, verificar que la fecha sea válida
    if (controller.esTemporal.value) {
      return controller.esFechaExpiracionValida;
    }

    // Si es permanente, solo necesita el amigo seleccionado
    return true;
  }
}
