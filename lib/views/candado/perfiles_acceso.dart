import 'package:ekeyless/controllers/candado/perfiles_acceso_controller.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VistaPerfilesAcceso extends StatelessWidget {
  const VistaPerfilesAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerfilesAccesoController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Perfiles: ${controller.candado.nombre}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.cargando.value && controller.perfiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.perfiles.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.cargarPerfiles,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 70),
                Icon(Icons.badge_outlined, size: 80, color: Colors.black26),
                SizedBox(height: 20),
                Text(
                  'No hay perfiles de acceso',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Crea una configuración reutilizable para no tener que construir cada autorización desde cero.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.cargarPerfiles,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.perfiles.length,
            itemBuilder: (context, index) {
              return _PerfilCard(
                perfil: controller.perfiles[index],
                controller: controller,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.nuevoPerfil,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo perfil'),
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  const _PerfilCard({required this.perfil, required this.controller});

  final PerfilAcceso perfil;
  final PerfilesAccesoController controller;

  @override
  Widget build(BuildContext context) {
    final color = _colorTipo(perfil.tipoAcceso);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(30),
                  foregroundColor: color,
                  child: Icon(_iconTipo(perfil.tipoAcceso)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        perfil.nombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${perfil.tipoAcceso.label} · ${perfil.canalComunicacion.label}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _menu(value),
                  itemBuilder:
                      (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'duplicar',
                          child: Text('Duplicar'),
                        ),
                        PopupMenuItem(
                          value: 'revocar',
                          child: Text('Revocar autorización'),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar perfil'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.person_outline,
              text: 'Usuario: ${perfil.usuarioId}',
            ),
            const SizedBox(height: 7),
            _InfoRow(
              icon: Icons.event_outlined,
              text: controller.descripcionVigencia(perfil),
            ),
            const SizedBox(height: 7),
            _InfoRow(
              icon: Icons.devices_outlined,
              text:
                  'Dispositivo: ${perfil.dispositivoId?.isNotEmpty == true ? perfil.dispositivoId : 'No especificado'}',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    controller.cargando.value
                        ? null
                        : () => controller.asignarPerfil(perfil),
                icon: const Icon(Icons.assignment_turned_in_outlined),
                label: const Text('Asignar y generar autorización'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _menu(String value) {
    switch (value) {
      case 'editar':
        controller.editarPerfil(perfil);
        break;
      case 'duplicar':
        controller.confirmarAccion(
          titulo: 'Duplicar perfil',
          mensaje: 'Se creará una copia independiente de "${perfil.nombre}".',
          textoConfirmar: 'Duplicar',
          accion: () => controller.duplicarPerfil(perfil),
        );
        break;
      case 'revocar':
        controller.confirmarAccion(
          titulo: 'Revocar autorización',
          mensaje:
              'Se eliminará el acceso actualmente generado para este perfil.',
          textoConfirmar: 'Revocar',
          accion: () => controller.revocarPerfil(perfil),
        );
        break;
      case 'eliminar':
        controller.confirmarAccion(
          titulo: 'Eliminar perfil',
          mensaje: 'El perfil se eliminará de forma permanente.',
          textoConfirmar: 'Eliminar',
          accion: () => controller.eliminarPerfil(perfil),
        );
        break;
    }
  }

  IconData _iconTipo(TipoAccesoPerfil tipo) {
    switch (tipo) {
      case TipoAccesoPerfil.permanente:
        return Icons.all_inclusive;
      case TipoAccesoPerfil.recurrente:
        return Icons.repeat;
      case TipoAccesoPerfil.temporal:
        return Icons.timer_outlined;
    }
  }

  Color _colorTipo(TipoAccesoPerfil tipo) {
    switch (tipo) {
      case TipoAccesoPerfil.permanente:
        return Colors.green;
      case TipoAccesoPerfil.recurrente:
        return Colors.blue;
      case TipoAccesoPerfil.temporal:
        return Colors.orange;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}
