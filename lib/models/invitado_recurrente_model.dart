class InvitadoRecurrente {
  final String usuarioId;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final List<int> diasPermitidos;
  final int horaInicioMinutos;
  final int horaFinMinutos;
  final String canalComunicacion;
  final String? dispositivoId;
  final int zonaHorariaOffsetMinutos;

  const InvitadoRecurrente({
    required this.usuarioId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasPermitidos,
    required this.horaInicioMinutos,
    required this.horaFinMinutos,
    required this.canalComunicacion,
    required this.dispositivoId,
    required this.zonaHorariaOffsetMinutos,
  });

  factory InvitadoRecurrente.fromJson(Map<String, dynamic> map) {
    final dias = (map['diasPermitidos'] as List<dynamic>?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .where((e) => e >= 1 && e <= 7)
            .toList() ??
        const <int>[];

    return InvitadoRecurrente(
      usuarioId: map['usuarioId']?.toString() ?? '',
      fechaInicio: DateTime.tryParse(map['fechaInicio']?.toString() ?? '') ?? DateTime.now(),
      fechaFin: map['fechaFin'] == null
          ? null
          : DateTime.tryParse(map['fechaFin'].toString()),
      diasPermitidos: List<int>.unmodifiable(dias),
      horaInicioMinutos: _parseMinutes(map['horaInicio']) ?? 0,
      horaFinMinutos: _parseMinutes(map['horaFin']) ?? 1439,
      canalComunicacion: map['canalComunicacion']?.toString() ?? 'bluetooth',
      dispositivoId: map['dispositivoId']?.toString(),
      zonaHorariaOffsetMinutos:
          int.tryParse(map['zonaHorariaOffsetMinutos']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'diasPermitidos': diasPermitidos,
      'horaInicio': _formatMinutes(horaInicioMinutos),
      'horaFin': _formatMinutes(horaFinMinutos),
      'canalComunicacion': canalComunicacion,
      'dispositivoId': dispositivoId,
      'zonaHorariaOffsetMinutos': zonaHorariaOffsetMinutos,
    };
  }

  bool tieneAcceso(DateTime ahora) {
    final referencia = ahora.toUtc().add(Duration(minutes: zonaHorariaOffsetMinutos));
    final inicioLocal = fechaInicio.toUtc().add(Duration(minutes: zonaHorariaOffsetMinutos));
    final finLocal = fechaFin?.toUtc().add(Duration(minutes: zonaHorariaOffsetMinutos));

    if (referencia.isBefore(inicioLocal)) return false;
    if (finLocal != null && referencia.isAfter(finLocal)) return false;

    if (!diasPermitidos.contains(referencia.weekday)) return false;

    final minutos = referencia.hour * 60 + referencia.minute;
    return minutos >= horaInicioMinutos && minutos <= horaFinMinutos;
  }

  InvitadoRecurrente copyWith({
    String? usuarioId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool clearFechaFin = false,
    List<int>? diasPermitidos,
    int? horaInicioMinutos,
    int? horaFinMinutos,
    String? canalComunicacion,
    String? dispositivoId,
    bool clearDispositivoId = false,
    int? zonaHorariaOffsetMinutos,
  }) {
    return InvitadoRecurrente(
      usuarioId: usuarioId ?? this.usuarioId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: clearFechaFin ? null : (fechaFin ?? this.fechaFin),
      diasPermitidos: List<int>.unmodifiable(diasPermitidos ?? this.diasPermitidos),
      horaInicioMinutos: horaInicioMinutos ?? this.horaInicioMinutos,
      horaFinMinutos: horaFinMinutos ?? this.horaFinMinutos,
      canalComunicacion: canalComunicacion ?? this.canalComunicacion,
      dispositivoId: clearDispositivoId ? null : (dispositivoId ?? this.dispositivoId),
      zonaHorariaOffsetMinutos:
          zonaHorariaOffsetMinutos ?? this.zonaHorariaOffsetMinutos,
    );
  }

  static int? _parseMinutes(dynamic value) {
    if (value == null) return null;
    final parts = value.toString().split(':');
    if (parts.length < 2) return int.tryParse(value.toString());
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  static String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }
}
