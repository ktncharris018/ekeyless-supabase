import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

class ConfiguracionTemporal extends StatelessWidget {
  final CompartirAccesoController controller;
  final bool visible;

  const ConfiguracionTemporal({super.key, 
    required this.controller,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración temporal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para seleccionar fecha + hora (como en el primer código)
              Obx(() {
                final fechaSel = controller.fechaHoraExpiracion;
                final label =
                    fechaSel == null
                        ? 'Selecciona fecha y hora de expiración'
                        : DateFormat('dd/MM/yyyy HH:mm').format(fechaSel);

                return TextButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Colors.orange),
                  label: Text(label, style: const TextStyle(fontSize: 14)),
                  onPressed: () async {
                    // Primero elijo la fecha
                    final ahora = DateTime.now();
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: ahora.add(const Duration(days: 1)),
                      firstDate: ahora,
                      lastDate: DateTime(2100),
                    );
                    if (fecha == null) return;

                    // Luego la hora
                    final hora = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime: TimeOfDay(
                        hour: ahora.hour,
                        minute: ahora.minute,
                      ),
                    );
                    if (hora == null) return;

                    // Combino fecha + hora
                    final combinado = DateTime(
                      fecha.year,
                      fecha.month,
                      fecha.day,
                      hora.hour,
                      hora.minute,
                    );

                    // Actualizo el controlador con la fecha combinada
                    controller.seleccionarFechaExpiracion(combinado);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Vista previa (solo se muestra si hay fecha seleccionada)
              Obx(() {
                final fechaHora = controller.fechaHoraExpiracion;
                if (fechaHora == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'El acceso expirará el:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(fechaHora),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}