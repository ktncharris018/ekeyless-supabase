import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ekeyless/models/notificacion_model.dart';
import 'package:ekeyless/services/notificaciones/notificacion_service.dart';

class NotificacionController extends GetxController {
  final RxList<NotificacionModel> notificaciones = <NotificacionModel>[].obs;
  final SupabaseClient _client = Supabase.instance.client;
  StreamSubscription? _suscripcion;

  @override
  void onInit() {
    super.onInit();
    _escucharNotificaciones();
  }

  @override
  void onClose() {
    _suscripcion?.cancel();
    super.onClose();
  }

  void _escucharNotificaciones() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    _suscripcion = NotificacionService().obtenerNotificaciones(uid).listen((
      lista,
    ) {
      notificaciones.value = lista;
    });
  }

  Future<void> marcarComoLeida(String idNotificacion) async {
    await NotificacionService().marcarComoLeida(idNotificacion);
  }

  Future<void> eliminarNotificacion(String idNotificacion) async {
    await NotificacionService().eliminarNotificacion(idNotificacion);
  }
}
