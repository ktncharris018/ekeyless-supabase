import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/validator_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndicadorFortaleza extends StatelessWidget {
  final RegistroController controller;
  final ThemeData theme;

  const IndicadorFortaleza({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fortaleza = controller.fortalezaContrasena.value;
      final passwordText = controller.passwordText.value;

      if (passwordText.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: fortaleza.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ValidatorUtils.getColorFortaleza(fortaleza),
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                ValidatorUtils.getMensajeFortaleza(fortaleza),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ValidatorUtils.getColorFortaleza(fortaleza),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
