import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndicadorCoincidencia extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const IndicadorCoincidencia({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final confirmPasswordText = controller.confirmPasswordText.value;
      final passwordText = controller.passwordText.value;

      if (confirmPasswordText.isEmpty) {
        return const SizedBox.shrink();
      }

      final coinciden = passwordText == confirmPasswordText;

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              coinciden ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: coinciden ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 6),
            Text(
              coinciden
                  ? 'Las contraseñas coinciden'
                  : 'Las contraseñas no coinciden',
              style: theme.textTheme.bodySmall?.copyWith(
                color: coinciden ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}
