import 'package:ekeyless/controllers/candado/candado_ble_controller.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VistaVincularCandado extends StatelessWidget {
  const VistaVincularCandado({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandadoBLEController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.iniciarVinculacion();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Vincular Candado',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.applyOpacity(Colors.black, 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 48,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Buscando Candados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Asegúrate de que tu candado esté encendido y cerca',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Obx(() {
              if (controller.escaneoActivo.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Escaneando dispositivos...',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              } else if (controller.escaneoFinalizado.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Escaneo completado',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 20),

            const Text(
              'Candados encontrados:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (controller.dispositivosDisponibles.isEmpty &&
                    controller.escaneoFinalizado.value) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron candados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verifica que esté encendido y cerca',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ColorUtils.applyOpacity(Colors.black, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: controller.dispositivosDisponibles.length,
                    itemBuilder: (context, index) {
                      final dispositivo =
                          controller.dispositivosDisponibles[index];
                      final seleccionado =
                          controller.dispositivoSeleccionado.value ==
                          dispositivo;

                      return Container(
                        margin: EdgeInsets.only(
                          bottom:
                              index ==
                                      controller
                                              .dispositivosDisponibles
                                              .length -
                                          1
                                  ? 0
                                  : 1,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  seleccionado
                                      ? Colors.blue[100]
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color:
                                  seleccionado
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            dispositivo.platformName.isNotEmpty
                                ? dispositivo.platformName
                                : 'Candado sin nombre',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  seleccionado
                                      ? Colors.blue[700]
                                      : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            dispositivo.remoteId.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            seleccionado
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                seleccionado
                                    ? Colors.blue[600]
                                    : Colors.grey[400],
                          ),
                          onTap:
                              () => controller.seleccionarDispositivo(
                                seleccionado ? null : dispositivo,
                              ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.iniciarVinculacion,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Escanear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed:
                          controller.cargando.value ||
                                  controller.dispositivoSeleccionado.value ==
                                      null
                              ? null
                              : controller.vincularDispositivo,
                      icon:
                          controller.cargando.value
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.link),
                      label: Text(
                        controller.cargando.value
                            ? 'Vinculando...'
                            : 'Vincular',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Obx(() {
              if (controller.mensajeEstado.value.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.mensajeEstado.value,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}
