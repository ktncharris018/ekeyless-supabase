import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:ekeyless/widgets/candado/tarjeta_usuario.dart';
import 'package:flutter/material.dart';

class SubseccionInvitados extends StatelessWidget {
  final String titulo;
  final Color color;
  final List<UsuarioModel> usuarios;
  final bool esPermanente;
  final Function(UsuarioModel) onRevocar;

  const SubseccionInvitados({super.key, 
    required this.titulo,
    required this.color,
    required this.usuarios,
    required this.esPermanente,
    required this.onRevocar,
  });

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
              color: ColorUtils.applyOpacity(color, 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  esPermanente ? Icons.admin_panel_settings : Icons.schedule,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${usuarios.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          ...usuarios.map(
            (usuario) => TarjetaUsuario(
              usuario: usuario,
              onRevocar: () => onRevocar(usuario),
              esPermanente: esPermanente,
            ),
          ),
        ],
      ),
    );
  }
}