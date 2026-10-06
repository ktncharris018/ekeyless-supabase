import 'package:ekeyless/models/perfil_acceso_model.dart';

import 'autorizacion.dart';

/// Singleton que mantiene el único contexto activo de control de acceso.
class AccessSessionManager {
  AccessSessionManager._();

  static final AccessSessionManager instance = AccessSessionManager._();

  String? usuarioId;
  String? candadoKey;
  Autorizacion? autorizacionActiva;
  String? canalComunicacion;
  bool conectado = false;

  bool get activa => autorizacionActiva != null;

  void iniciar({
    required String usuarioId,
    required String candadoKey,
    required Autorizacion autorizacion,
  }) {
    this.usuarioId = usuarioId;
    this.candadoKey = candadoKey;
    autorizacionActiva = autorizacion;
    canalComunicacion = autorizacion.canalComunicacion.value;
    conectado = false;
  }

  void actualizarConexion(bool estado) {
    conectado = estado;
  }

  void cerrar() {
    usuarioId = null;
    candadoKey = null;
    autorizacionActiva = null;
    canalComunicacion = null;
    conectado = false;
  }
}
