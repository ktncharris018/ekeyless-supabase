import 'package:ekeyless/widgets/estructura/bottom_nav_bar.dart';
import 'package:ekeyless/widgets/estructura/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/notificaciones/notificacion_controller.dart';

class VistaNotificaciones extends StatelessWidget {
  const VistaNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificacionController>();
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notificaciones'),
      body: Center(child: Text('Notificaciones')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
