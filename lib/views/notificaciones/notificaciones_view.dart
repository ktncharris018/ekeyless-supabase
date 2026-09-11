import 'package:ekeyless/controllers/notificaciones/notificacion_controller.dart';
import 'package:ekeyless/models/notificacion_model.dart';
import 'package:ekeyless/widgets/estructura/bottom_nav_bar.dart';
import 'package:ekeyless/widgets/estructura/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificacionesView extends StatelessWidget {
  NotificacionesView({super.key});

  final NotificacionController _controller = Get.find(); // Usa Get.find() ya que está inyectado
  final Color azulClaro = const Color(0xFFE3F2FD); // Fondo azul suave

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notificaciones'),
      body: Obx(() {
        final notificaciones = _controller.notificaciones;

        if (notificaciones.isEmpty) {
          return const Center(
            child: Text(
              'No tienes notificaciones aún.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notificaciones.length,
          itemBuilder: (context, index) {
            final noti = notificaciones[index];
            return _buildNotificacionCard(noti);
          },
        );
      }),
      backgroundColor: const Color(0xFFF4F4F4),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildNotificacionCard(NotificacionModel noti) {
    final bool leida = noti.leido;

    return GestureDetector(
      onTap: () {
        if (!leida) {
          _controller.marcarComoLeida(noti.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: leida ? Colors.white : azulClaro,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: const Icon(Icons.notifications, color: Colors.indigo),
          title: Text(
            noti.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(noti.cuerpo),
              const SizedBox(height: 4),
              Text(
                noti.tiempoTranscurrido, // <-- Método del modelo, se actualiza solo
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
