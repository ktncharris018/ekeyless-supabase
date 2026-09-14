import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SugerenciasPassword extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const SugerenciasPassword({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final passwordText = controller.passwordText.value;
      final sugerencias = controller.getSugerenciasContrasena();

      if (sugerencias.isEmpty || passwordText.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorUtils.applyOpacity(Colors.orange, 0.1),
          border: Border.all(
            color: ColorUtils.applyOpacity(Colors.orange, 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 6),
                Text(
                  'Tu contraseña debe incluir:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sugerencias.map(
              (sugerencia) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        sugerencia,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
