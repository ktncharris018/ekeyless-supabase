import 'package:ekeyless/controllers/candado/candado_ble_controller.dart';
import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/widgets/estructura/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VistaListaCandados extends StatelessWidget {
  const VistaListaCandados({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandadoBLEController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mis Candados',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black12),
        ),
      ),
      body: Obx(() {
        if (controller.cargandoCandados.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Cargando candados...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (controller.candadosUsuario.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'No tienes candados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca el botón + para vincular tu primer candado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.cargarCandadosUsuario,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.candadosUsuario.length,
            itemBuilder: (context, index) {
              final candado = controller.candadosUsuario[index];
              final rol = candado.obtenerRolUsuario(
                controller.currentUser?.id ?? '',
              );
              final esDueno = rol == TipoUsuario.dueno;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: esDueno ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      esDueno ? Icons.lock : Icons.lock_open_outlined,
                      color: esDueno ? Colors.blue[700] : Colors.green[700],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    candado.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _obtenerTextoRol(rol),
                        style: TextStyle(
                          color: _obtenerColorRol(rol),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Creado: ${DateFormat('dd/MM/yyyy').format(candado.fechaCreacion)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'controlar':
                          controller.irAControlCandado(candado);
                          break;
                        case 'compartir':
                          controller.irACompartirAcceso(candado);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'controlar',
                            child: Row(
                              children: [
                                Icon(Icons.control_camera, size: 20),
                                SizedBox(width: 12),
                                Text('Controlar'),
                              ],
                            ),
                          ),
                          if (esDueno)
                            const PopupMenuItem(
                              value: 'compartir',
                              child: Row(
                                children: [
                                  Icon(Icons.share, size: 20),
                                  SizedBox(width: 12),
                                  Text('Compartir acceso'),
                                ],
                              ),
                            ),
                        ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.irAVincularCandado,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  String _obtenerTextoRol(TipoUsuario rol) {
    switch (rol) {
      case TipoUsuario.dueno:
        return 'PROPIETARIO';
      case TipoUsuario.invitado:
        return 'ACCESO PERMANENTE';
      case TipoUsuario.invitadoTemporal:
        return 'ACCESO TEMPORAL';
      default:
        return 'SIN ACCESO';
    }
  }

  Color _obtenerColorRol(TipoUsuario rol) {
    switch (rol) {
      case TipoUsuario.dueno:
        return Colors.blue[700]!;
      case TipoUsuario.invitado:
        return Colors.green[700]!;
      case TipoUsuario.invitadoTemporal:
        return Colors.orange[700]!;
      default:
        return Colors.red[700]!;
    }
  }
}
