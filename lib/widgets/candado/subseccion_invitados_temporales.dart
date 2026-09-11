import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:ekeyless/widgets/candado/tarjeta_usuario_temporal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubseccionInvitadosTemporales extends StatelessWidget {
  final CompartirAccesoController controller;

  const SubseccionInvitadosTemporales({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la subsección
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorUtils.applyOpacity(Colors.orange, 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Acceso Temporal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      '${controller.invitadosTemporales.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios temporales
          Obx(
            () => Column(
              children:
                  controller.invitadosTemporales.map((invitadoData) {
                    final usuario = invitadoData['usuario'] as UsuarioModel;
                    final fechaExpiracion =
                        invitadoData['fechaExpiracion'] as DateTime;
                    final activo = invitadoData['activo'] as bool;

                    return TarjetaUsuarioTemporal(
                      usuario: usuario,
                      fechaExpiracion: fechaExpiracion,
                      activo: activo,
                      controller: controller,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
