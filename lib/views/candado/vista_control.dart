import 'package:ekeyless/controllers/candado/candado_ble_controller.dart';
import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VistaControl extends StatelessWidget {
  const VistaControl({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandadoBLEController>();
    final candado = Get.arguments as CandadoModel;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await controller.volverAlListado();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            candado.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.volverAlListado,
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.black12),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final abierto = controller.esCandadoAbierto;
            final conectado = controller.conectado.value;

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  abierto
                                      ? [Colors.green[400]!, Colors.green[600]!]
                                      : [Colors.red[400]!, Colors.red[600]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorUtils.applyOpacity(
                                  (abierto ? Colors.green : Colors.red),
                                  0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            abierto ? Icons.lock_open : Icons.lock,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          abierto ? 'ABIERTO' : 'CERRADO',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                abierto ? Colors.green[700] : Colors.red[700],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                conectado ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  conectado
                                      ? Colors.green[200]!
                                      : Colors.red[200]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                conectado
                                    ? Icons.bluetooth_connected
                                    : Icons.bluetooth_disabled,
                                size: 16,
                                color:
                                    conectado
                                        ? Colors.green[700]
                                        : Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                conectado ? 'Conectado' : 'Desconectado',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      conectado
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (controller.mensajeEstado.value.isNotEmpty)
                          Text(
                            controller.mensajeEstado.value,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            conectado
                                ? () => controller.enviarComando(
                                  abierto ? 'CLOSE' : 'OPEN',
                                )
                                : null,
                        icon: Icon(abierto ? Icons.lock : Icons.lock_open),
                        label: Text(
                          abierto ? 'Cerrar Candado' : 'Abrir Candado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              abierto ? Colors.red[600] : Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              conectado
                                  ? Icons.bluetooth_disabled
                                  : Icons.bluetooth_searching,
                            ),
                            label: Text(conectado ? 'Desconectar' : 'Conectar'),
                            onPressed: () {
                              if (conectado) {
                                controller.desconectarCandado();
                              } else {
                                controller.reconectarCandado(candado);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        if (candado.obtenerRolUsuario(
                              controller.currentUser?.id ?? '',
                            ) ==
                            TipoUsuario.dueno) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.share),
                              label: const Text('Compartir'),
                              onPressed:
                                  () => controller.irACompartirAcceso(candado),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
