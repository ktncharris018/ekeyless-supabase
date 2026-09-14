import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectorTipoAcceso extends StatelessWidget {
  final CompartirAccesoController controller;

  const SelectorTipoAcceso({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de acceso',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Obx(
          () => Column(
            children: [
              // Acceso permanente
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        !controller.esTemporal.value
                            ? Colors.green
                            : Colors.grey[300]!,
                    width: !controller.esTemporal.value ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<bool>(
                  value: false,
                  groupValue: controller.esTemporal.value,
                  onChanged: (value) => controller.cambiarTipoAcceso(value!),
                  title: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Acceso Permanente',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text('El usuario tendrá acceso indefinido'),
                  activeColor: Colors.green,
                ),
              ),

              const SizedBox(height: 12),

              // Acceso temporal
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        controller.esTemporal.value
                            ? Colors.orange
                            : Colors.grey[300]!,
                    width: controller.esTemporal.value ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<bool>(
                  value: true,
                  groupValue: controller.esTemporal.value,
                  onChanged: (value) => controller.cambiarTipoAcceso(value!),
                  title: const Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Acceso Temporal',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'El acceso expirará en una fecha específica',
                  ),
                  activeColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}