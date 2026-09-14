import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/auth/registro_controller.dart';

class OpcionesFotoBottomSheet {
  static void mostrar(
    BuildContext context,
    ThemeData theme,
    RegistroController controller,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  Text(
                    'Selecciona una opción',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GetBuilder<RegistroController>(
              builder: (controller) {
                final tieneImagen = controller.imageSelected.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _opcion('Cámara', Icons.camera_alt, () {
                        Get.back();
                        controller.tomarFoto();
                      }, Colors.blue),
                      _opcion('Galería', Icons.photo_library, () {
                        Get.back();
                        controller.seleccionarImagen();
                      }, Colors.blue),
                      if (tieneImagen)
                        _opcion('Eliminar', Icons.delete, () {
                          Get.back();
                          controller.eliminarImagen();
                        }, Colors.red),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  static Widget _opcion(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
