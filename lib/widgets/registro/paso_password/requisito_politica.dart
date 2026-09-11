import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/material.dart';

class RequisitoPolitica extends StatelessWidget {
  final String text;

  const RequisitoPolitica({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: ColorUtils.applyOpacity(AppColors.primary, 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: ColorUtils.applyOpacity(AppColors.primary, 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
