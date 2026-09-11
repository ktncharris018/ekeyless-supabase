import 'package:ekeyless/models/usuario_model.dart';
import 'package:flutter/material.dart';

class TarjetaUsuario extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onRevocar;
  final bool esPermanente;

  const TarjetaUsuario({super.key, 
    required this.usuario,
    required this.onRevocar,
    required this.esPermanente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
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

          // Botón revocar
          TextButton.icon(
            onPressed: onRevocar,
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            label: const Text('Revocar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}