import 'package:ekeyless/patterns/access/prototype.dart';

/// Tipo de autorización que puede generar un perfil.
enum TipoAccesoPerfil { permanente, recurrente, temporal }

/// Familia de comunicación que puede utilizar una autorización.
enum CanalComunicacion { bluetooth, nfc }

extension TipoAccesoPerfilX on TipoAccesoPerfil {
  String get value => name;

  String get label {
    switch (this) {
      case TipoAccesoPerfil.permanente:
        return 'Permanente';
      case TipoAccesoPerfil.recurrente:
        return 'Recurrente';
      case TipoAccesoPerfil.temporal:
        return 'Temporal';
    }
  }

  static TipoAccesoPerfil fromValue(String? value) {
    return TipoAccesoPerfil.values.firstWhere(
      (item) => item.value == value,
      orElse: () => TipoAccesoPerfil.permanente,
    );
  }
}

extension CanalComunicacionX on CanalComunicacion {
  String get value => name;

  String get label {
    switch (this) {
      case CanalComunicacion.bluetooth:
        return 'Bluetooth';
      case CanalComunicacion.nfc:
        return 'NFC';
    }
  }

  static CanalComunicacion fromValue(String? value) {
    return CanalComunicacion.values.firstWhere(
      (item) => item.value == value,
      orElse: () => CanalComunicacion.bluetooth,
    );
  }
}

/// Perfil reutilizable que contiene toda la configuración necesaria para
/// generar una autorización sin modificar el perfil original.
class PerfilAcceso extends Prototype<PerfilAcceso> {
  final String? id;
  final String propietarioId;
  final String nombre;
  final String candadoKey;
  final String usuarioId;
  final String? dispositivoId;
  final TipoAccesoPerfil tipoAcceso;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final List<int> diasPermitidos;
  final int? horaInicioMinutos;
  final int? horaFinMinutos;
  final CanalComunicacion canalComunicacion;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  const PerfilAcceso({
    required this.id,
    required this.propietarioId,
    required this.nombre,
    required this.candadoKey,
    required this.usuarioId,
    required this.dispositivoId,
    required this.tipoAcceso,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasPermitidos,
    required this.horaInicioMinutos,
    required this.horaFinMinutos,
    required this.canalComunicacion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory PerfilAcceso.nuevo({
    required String propietarioId,
    required String nombre,
    required String candadoKey,
    required String usuarioId,
    String? dispositivoId,
    required TipoAccesoPerfil tipoAcceso,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    List<int> diasPermitidos = const [],
    int? horaInicioMinutos,
    int? horaFinMinutos,
    CanalComunicacion canalComunicacion = CanalComunicacion.bluetooth,
  }) {
    final ahora = DateTime.now();
    return PerfilAcceso(
      id: null,
      propietarioId: propietarioId,
      nombre: nombre.trim(),
      candadoKey: candadoKey,
      usuarioId: usuarioId,
      dispositivoId: dispositivoId?.trim().isEmpty == true
          ? null
          : dispositivoId?.trim(),
      tipoAcceso: tipoAcceso,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      diasPermitidos: List<int>.unmodifiable(diasPermitidos),
      horaInicioMinutos: horaInicioMinutos,
      horaFinMinutos: horaFinMinutos,
      canalComunicacion: canalComunicacion,
      fechaCreacion: ahora,
      fechaActualizacion: ahora,
    );
  }

  factory PerfilAcceso.fromJson(Map<String, dynamic> json) {
    final dias = (json['dias_permitidos'] as List<dynamic>?)
            ?.map((value) => int.tryParse(value.toString()) ?? 0)
            .where((value) => value >= 1 && value <= 7)
            .toList() ??
        const <int>[];

    return PerfilAcceso(
      id: json['id']?.toString(),
      propietarioId: json['propietario_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      candadoKey: json['candado_key']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? '',
      dispositivoId: json['dispositivo_id']?.toString(),
      tipoAcceso: TipoAccesoPerfilX.fromValue(json['tipo_acceso']?.toString()),
      fechaInicio: _parseDateTime(json['fecha_inicio']),
      fechaFin: json['fecha_fin'] == null
          ? null
          : _parseDateTime(json['fecha_fin']),
      diasPermitidos: List<int>.unmodifiable(dias),
      horaInicioMinutos: _parseMinutes(json['hora_inicio']),
      horaFinMinutos: _parseMinutes(json['hora_fin']),
      canalComunicacion:
          CanalComunicacionX.fromValue(json['canal_comunicacion']?.toString()),
      fechaCreacion: _parseDateTime(json['created_at']),
      fechaActualizacion: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'propietario_id': propietarioId,
      'nombre': nombre,
      'candado_key': candadoKey,
      'usuario_id': usuarioId,
      'dispositivo_id': dispositivoId,
      'tipo_acceso': tipoAcceso.value,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'dias_permitidos': diasPermitidos,
      'hora_inicio': _minutesToSqlTime(horaInicioMinutos),
      'hora_fin': _minutesToSqlTime(horaFinMinutos),
      'canal_comunicacion': canalComunicacion.value,
      'updated_at': fechaActualizacion.toIso8601String(),
    };
  }

  PerfilAcceso copyWith({
    String? id,
    String? propietarioId,
    String? nombre,
    String? candadoKey,
    String? usuarioId,
    String? dispositivoId,
    bool clearDispositivoId = false,
    TipoAccesoPerfil? tipoAcceso,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool clearFechaFin = false,
    List<int>? diasPermitidos,
    int? horaInicioMinutos,
    bool clearHoraInicio = false,
    int? horaFinMinutos,
    bool clearHoraFin = false,
    CanalComunicacion? canalComunicacion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return PerfilAcceso(
      id: id ?? this.id,
      propietarioId: propietarioId ?? this.propietarioId,
      nombre: nombre ?? this.nombre,
      candadoKey: candadoKey ?? this.candadoKey,
      usuarioId: usuarioId ?? this.usuarioId,
      dispositivoId:
          clearDispositivoId ? null : (dispositivoId ?? this.dispositivoId),
      tipoAcceso: tipoAcceso ?? this.tipoAcceso,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: clearFechaFin ? null : (fechaFin ?? this.fechaFin),
      diasPermitidos: List<int>.unmodifiable(
        diasPermitidos ?? this.diasPermitidos,
      ),
      horaInicioMinutos:
          clearHoraInicio ? null : (horaInicioMinutos ?? this.horaInicioMinutos),
      horaFinMinutos:
          clearHoraFin ? null : (horaFinMinutos ?? this.horaFinMinutos),
      canalComunicacion: canalComunicacion ?? this.canalComunicacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String get prototypeKey => id ?? '$propietarioId:$candadoKey:$nombre';

  @override
  PerfilAcceso clone() {
    return PerfilAcceso(
      id: null,
      propietarioId: propietarioId,
      nombre: nombre,
      candadoKey: candadoKey,
      usuarioId: usuarioId,
      dispositivoId: dispositivoId,
      tipoAcceso: tipoAcceso,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      diasPermitidos: List<int>.unmodifiable(diasPermitidos),
      horaInicioMinutos: horaInicioMinutos,
      horaFinMinutos: horaFinMinutos,
      canalComunicacion: canalComunicacion,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );
  }

  String get rangoHorario {
    if (horaInicioMinutos == null || horaFinMinutos == null) {
      return 'Todo el día';
    }
    return '${_formatMinutes(horaInicioMinutos!)} - ${_formatMinutes(horaFinMinutos!)}';
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static int? _parseMinutes(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    final parts = value.toString().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  static String? _minutesToSqlTime(int? minutes) {
    if (minutes == null) return null;
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  static String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
