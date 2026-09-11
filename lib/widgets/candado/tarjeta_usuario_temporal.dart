import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:flutter/material.dart';

class TarjetaUsuarioTemporal extends StatelessWidget {
  final UsuarioModel usuario;
  final DateTime fechaExpiracion;
  final bool activo;
  final CompartirAccesoController controller;

  const TarjetaUsuarioTemporal({super.key, 
    required this.usuario,
    required this.fechaExpiracion,
    required this.activo,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar del usuario
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Text(
                  usuario.nombreUsuario.isNotEmpty
                      ? usuario.nombreUsuario[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombreUsuario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (usuario.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        usuario.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activo ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activo ? 'Activo' : 'Expirado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: activo ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Información de expiración y acciones
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      activo ? 'Expira: ' : 'Expiró: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      controller.formatearFecha(fechaExpiracion),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (activo) ...[
                  const SizedBox(height: 8),
                  Text(
                    controller.obtenerEstadoAccesoTemporal(fechaExpiracion),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Botones de acción
                Row(
                  children: [
                    if (activo) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _mostrarDialogoExtender(context),
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('Extender'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: TextButton.icon(
                        onPressed:
                            () => controller.revocarAccesoTemporal(usuario),
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        label: const Text('Revocar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoExtender(BuildContext context) {
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Extender Acceso'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Extender acceso para ${usuario.nombreUsuario}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // Selector de fecha
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          fechaSeleccionada != null
                              ? '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}'
                              : 'Seleccionar fecha',
                        ),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (fecha != null) {
                            setState(() => fechaSeleccionada = fecha);
                          }
                        },
                      ),

                      // Selector de hora
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          horaSeleccionada != null
                              ? '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}'
                              : 'Seleccionar hora',
                        ),
                        onTap: () async {
                          final hora = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (hora != null) {
                            setState(() => horaSeleccionada = hora);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed:
                          fechaSeleccionada != null
                              ? () {
                                final nuevaFecha = DateTime(
                                  fechaSeleccionada!.year,
                                  fechaSeleccionada!.month,
                                  fechaSeleccionada!.day,
                                  horaSeleccionada?.hour ?? 23,
                                  horaSeleccionada?.minute ?? 59,
                                );

                                controller.extenderAccesoTemporal(
                                  usuario,
                                  nuevaFecha,
                                );
                                Navigator.of(context).pop();
                              }
                              : null,
                      child: const Text('Extender'),
                    ),
                  ],
                ),
          ),
    );
  }
}
