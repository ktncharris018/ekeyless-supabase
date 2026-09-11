import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/widgets/candado/subseccion_invitados_permanentes.dart';
import 'package:ekeyless/widgets/candado/subseccion_invitados_temporales.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeccionUsuariosConAcceso extends StatelessWidget {
  final CompartirAccesoController controller;

  const SeccionUsuariosConAcceso({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usuarios con acceso',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (controller.cargandoInvitados.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final hayInvitados =
              controller.invitadosPermanentes.isNotEmpty ||
              controller.invitadosTemporales.isNotEmpty;

          if (!hayInvitados) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No has compartido acceso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Los usuarios con acceso aparecerán aquí',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Invitados permanentes
              if (controller.invitadosPermanentes.isNotEmpty) ...[
                SubseccionInvitados(
                  titulo: 'Acceso Permanente',
                  color: Colors.green,
                  usuarios: controller.invitadosPermanentes,
                  esPermanente: true,
                  onRevocar: controller.revocarAccesoPermanente,
                ),
                const SizedBox(height: 16),
              ],

              // Invitados temporales
              if (controller.invitadosTemporales.isNotEmpty)
                SubseccionInvitadosTemporales(controller: controller),
            ],
          );
        }),
      ],
    );
  }
}