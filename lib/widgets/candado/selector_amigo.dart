import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectorAmigo extends StatelessWidget {
  final CompartirAccesoController controller;

  const SelectorAmigo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar amigo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (controller.cargandoAmigos.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final amigosDisponibles = controller.amigosDisponibles;

          if (amigosDisponibles.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay amigos disponibles',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Todos tus amigos ya tienen acceso',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<UsuarioModel>(
              isExpanded: true,
              initialValue: controller.amigoSeleccionado.value,
              decoration: const InputDecoration(
                hintText: 'Selecciona un amigo',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  amigosDisponibles.map((amigo) {
                    return DropdownMenuItem<UsuarioModel>(
                      value: amigo,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              amigo.nombreUsuario.isNotEmpty
                                  ? amigo.nombreUsuario[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              amigo.nombreUsuario,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: controller.seleccionarAmigo,
            ),
          );
        }),
      ],
    );
  }
}
