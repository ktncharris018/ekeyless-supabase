import 'package:ekeyless/controllers/amigos/amigos_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AmigoItem extends StatelessWidget {
  final String nombreUsuario;
  final String? avatarUrl;
  final String usuarioId;
  final String categoria; 
  final VoidCallback? onAgregar;
  final VoidCallback? onAceptar;
  final VoidCallback? onCancelar;

  AmigoItem({
    super.key,
    required this.nombreUsuario,
    this.avatarUrl,
    required this.usuarioId,
    required this.categoria,
    this.onAgregar,
    this.onAceptar,
    this.onCancelar,
  });

  final AmigosController userController = Get.find<AmigosController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentUser = userController.currentUser.value;

      if (currentUser == null) {
        return const SizedBox.shrink(); 
      }

      return Column(
        children: [
          const Divider(
            color: Colors.white,
            thickness: 3.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Image.asset(
                        'assets/default_avatar.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/default_avatar.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      
              ),  
            ),

            title: Text(
              nombreUsuario,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: _buildBotones(currentUser.id),
            onTap: () {
              // Acción al tocar el amigo
            },
          ),
        ],
      );
    });
  }

  Widget? _buildBotones(String receptorId) {
    if (categoria == 'Solicitudes') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _boton(
            label: 'Aceptar',
            color: Colors.green.withAlpha((0.4 * 255).toInt()),
            onPressed: () {
              userController.aceptarSolicitud(usuarioId);
            },
          ),
          const SizedBox(width: 8),
          _boton(
            label: 'Cancelar',
            color: Colors.red.withAlpha((0.4 * 255).toInt()),
            onPressed: () {
              userController.cancelarSolicitud(receptorId);
            },
          ),
        ],
      );
    } else if (categoria == 'Agregar') {
      return _boton(
        label: 'Agregar',
        color: Colors.blue.withAlpha((0.4 * 255).toInt()),
        onPressed: () {
          userController.enviarSolicitudAmistad(usuarioId);
        },
      );
    } else {
      return null; 
    }
  }

  Widget _boton({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
