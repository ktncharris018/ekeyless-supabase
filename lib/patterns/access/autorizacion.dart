import 'package:ekeyless/models/perfil_acceso_model.dart';

class Autorizacion {
  final String usuarioId;
  final String candadoKey;
  final String? dispositivoId;
  final TipoAccesoPerfil tipoAcceso;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final List<int> diasPermitidos;
  final int? horaInicioMinutos;
  final int? horaFinMinutos;
  final CanalComunicacion canalComunicacion;
  final String estado;

  const Autorizacion({
    required this.usuarioId,
    required this.candadoKey,
    required this.dispositivoId,
    required this.tipoAcceso,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasPermitidos,
    required this.horaInicioMinutos,
    required this.horaFinMinutos,
    required this.canalComunicacion,
    this.estado = 'activa',
  });
}
