import 'package:ekeyless/models/perfil_acceso_model.dart';

abstract interface class Autorizacion {
  String get usuarioId;
  String get candadoKey;
  String? get dispositivoId;
  TipoAccesoPerfil get tipoAcceso;
  DateTime get fechaInicio;
  DateTime? get fechaFin;
  List<int> get diasPermitidos;
  int? get horaInicioMinutos;
  int? get horaFinMinutos;
  CanalComunicacion get canalComunicacion;
  String get estado;
}

abstract class _AutorizacionBase implements Autorizacion {
  const _AutorizacionBase({
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

  @override
  final String usuarioId;

  @override
  final String candadoKey;

  @override
  final String? dispositivoId;

  @override
  final TipoAccesoPerfil tipoAcceso;

  @override
  final DateTime fechaInicio;

  @override
  final DateTime? fechaFin;

  @override
  final List<int> diasPermitidos;

  @override
  final int? horaInicioMinutos;

  @override
  final int? horaFinMinutos;

  @override
  final CanalComunicacion canalComunicacion;

  @override
  final String estado;
}

class AutorizacionPermanente extends _AutorizacionBase {
  const AutorizacionPermanente({
    required String usuarioId,
    required String candadoKey,
    required String? dispositivoId,
    required DateTime fechaInicio,
    required List<int> diasPermitidos,
    required int? horaInicioMinutos,
    required int? horaFinMinutos,
    required CanalComunicacion canalComunicacion,
  }) : super(
          usuarioId: usuarioId,
          candadoKey: candadoKey,
          dispositivoId: dispositivoId,
          tipoAcceso: TipoAccesoPerfil.permanente,
          fechaInicio: fechaInicio,
          fechaFin: null,
          diasPermitidos: diasPermitidos,
          horaInicioMinutos: horaInicioMinutos,
          horaFinMinutos: horaFinMinutos,
          canalComunicacion: canalComunicacion,
        );
}

class AutorizacionTemporal extends _AutorizacionBase {
  const AutorizacionTemporal({
    required String usuarioId,
    required String candadoKey,
    required String? dispositivoId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<int> diasPermitidos,
    required int? horaInicioMinutos,
    required int? horaFinMinutos,
    required CanalComunicacion canalComunicacion,
  }) : super(
          usuarioId: usuarioId,
          candadoKey: candadoKey,
          dispositivoId: dispositivoId,
          tipoAcceso: TipoAccesoPerfil.temporal,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          diasPermitidos: diasPermitidos,
          horaInicioMinutos: horaInicioMinutos,
          horaFinMinutos: horaFinMinutos,
          canalComunicacion: canalComunicacion,
        );
}

class AutorizacionRecurrente extends _AutorizacionBase {
  const AutorizacionRecurrente({
    required String usuarioId,
    required String candadoKey,
    required String? dispositivoId,
    required DateTime fechaInicio,
    required DateTime? fechaFin,
    required List<int> diasPermitidos,
    required int horaInicioMinutos,
    required int horaFinMinutos,
    required CanalComunicacion canalComunicacion,
  }) : super(
          usuarioId: usuarioId,
          candadoKey: candadoKey,
          dispositivoId: dispositivoId,
          tipoAcceso: TipoAccesoPerfil.recurrente,
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          diasPermitidos: diasPermitidos,
          horaInicioMinutos: horaInicioMinutos,
          horaFinMinutos: horaFinMinutos,
          canalComunicacion: canalComunicacion,
        );
}
