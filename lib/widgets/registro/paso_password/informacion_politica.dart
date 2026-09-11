import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';

import 'requisito_politica.dart';

class InformacionPolitica extends StatelessWidget {
  final ThemeData theme;

  const InformacionPolitica({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.applyOpacity(AppColors.primary, 0.05),
        border: Border.all(
          color: ColorUtils.applyOpacity(AppColors.primary, 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Política de contraseñas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const RequisitoPolitica(text: '8-12 caracteres de longitud'),
          const RequisitoPolitica(text: 'Al menos una letra mayúscula (A-Z)'),
          const RequisitoPolitica(text: 'Al menos una letra minúscula (a-z)'),
          const RequisitoPolitica(text: 'Al menos un número (0-9)'),
          const RequisitoPolitica(
            text: 'Al menos un carácter especial (!@#\$%^&*)',
          ),
          const RequisitoPolitica(text: 'Sin espacios en blanco'),
        ],
      ),
    );
  }
}
