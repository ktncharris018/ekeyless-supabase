import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/utils/app_color.dart';
import 'package:ekeyless/utils/color_util.dart';
import 'package:flutter/foundation.dart';

class AvatarSelector extends StatelessWidget {
  final RegistroController controller;
  final VoidCallback onTap;

  const AvatarSelector({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<RegistroController>(
        builder: (_) {
          return GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: ColorUtils.applyOpacity(
                    AppColors.primary,
                    0.1,
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: _buildImageWidget(controller),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(RegistroController controller) {
    final hasImage = controller.imageSelected.value;

    if (!hasImage) return _defaultAvatarOrIcon();

    if (kIsWeb && controller.imagenWebUrl.value.isNotEmpty) {
      return Image.network(controller.imagenWebUrl.value, fit: BoxFit.cover);
    } else if (controller.imagenPerfilFile.value != null) {
      return Image.file(controller.imagenPerfilFile.value!, fit: BoxFit.cover);
    } else if (controller.imagenPerfilXFile.value != null) {
      return FutureBuilder<Uint8List>(
        future: controller.imagenPerfilXFile.value?.readAsBytes(),
        builder:
            (context, snapshot) =>
                snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : _defaultAvatarOrIcon(),
      );
    }

    return _defaultAvatarOrIcon();
  }

  Widget _defaultAvatarOrIcon() {
    return Image.asset(
      'assets/default_avatar.png',
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) =>
              const Icon(Icons.person, size: 60, color: AppColors.primary),
    );
  }
}
