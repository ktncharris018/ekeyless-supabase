class CandadoModel {
  final String key; // La key del candado
  final String nombre;
  final String dueno;
  final List<String> invitadosPermanentes;
  final List<InvitadoTemporal> invitadosTemporales;
  final DateTime fechaCreacion;

  CandadoModel({
    required this.key,
    required this.nombre,
    required this.dueno,
    this.invitadosPermanentes = const [],
    this.invitadosTemporales = const [],
    required this.fechaCreacion,
  });

  static DateTime _parseFecha(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }

  factory CandadoModel.fromJson(Map<String, dynamic> map) {
    return CandadoModel(
      key: map['key'] ?? '',
      nombre: map['nombre'] ?? '',
      dueno: map['dueno'] ?? '',
      invitadosPermanentes: List<String>.from(
        map['invitadosPermanentes'] ?? [],
      ),
      invitadosTemporales:
          (map['invitadosTemporales'] as List<dynamic>?)
              ?.map((e) => InvitadoTemporal.fromJson(e))
              .toList() ??
          [],
      fechaCreacion: _parseFecha(map['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'nombre': nombre,
      'dueno': dueno,
      'invitadosPermanentes': invitadosPermanentes,
      'invitadosTemporales':
          invitadosTemporales.map((e) => e.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Verificar si un usuario tiene acceso al candado
  bool tieneAcceso(String usuarioId) {
    if (dueno == usuarioId) return true;
    if (invitadosPermanentes.contains(usuarioId)) return true;

    // Verificar invitados temporales no expirados
    final ahora = DateTime.now();
    return invitadosTemporales.any(
      (invitado) =>
          invitado.usuarioId == usuarioId &&
          invitado.fechaExpiracion.isAfter(ahora),
    );
  }

  // Obtener el rol del usuario
  TipoUsuario obtenerRolUsuario(String usuarioId) {
    if (dueno == usuarioId) return TipoUsuario.dueno;
    if (invitadosPermanentes.contains(usuarioId)) return TipoUsuario.invitado;

    final ahora = DateTime.now();
    final invitadoTemporal = invitadosTemporales.firstWhere(
      (invitado) => invitado.usuarioId == usuarioId,
      orElse:
          () =>
              InvitadoTemporal(usuarioId: '', fechaExpiracion: DateTime.now()),
    );

    if (invitadoTemporal.usuarioId.isNotEmpty &&
        invitadoTemporal.fechaExpiracion.isAfter(ahora)) {
      return TipoUsuario.invitadoTemporal;
    }

    return TipoUsuario.desconocido;
  }

  CandadoModel copyWith({
    String? key,
    String? nombre,
    String? dueno,
    List<String>? invitadosPermanentes,
    List<InvitadoTemporal>? invitadosTemporales,
    DateTime? fechaCreacion,
  }) {
    return CandadoModel(
      key: key ?? this.key,
      nombre: nombre ?? this.nombre,
      dueno: dueno ?? this.dueno,
      invitadosPermanentes: invitadosPermanentes ?? this.invitadosPermanentes,
      invitadosTemporales: invitadosTemporales ?? this.invitadosTemporales,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

class InvitadoTemporal {
  final String usuarioId;
  final DateTime fechaExpiracion;

  InvitadoTemporal({required this.usuarioId, required this.fechaExpiracion});

  factory InvitadoTemporal.fromJson(Map<String, dynamic> map) {
    return InvitadoTemporal(
      usuarioId: map['usuarioId'] ?? '',
      fechaExpiracion: DateTime.parse(map['fechaExpiracion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'fechaExpiracion': fechaExpiracion.toIso8601String(),
    };
  }
}

enum TipoUsuario { dueno, invitado, invitadoTemporal, desconocido }

enum EstadoCandado { cerrado, abierto, desconectado, abriendo, cerrando, error }

// Estados del candado desde el ESP32
class EstadoCandadoBLE {
  static const String conectado = 'CONNECTED';
  static const String abierto = 'OPENED';
  static const String cerrado = 'CLOSED';
  static const String yaAbierto = 'ALREADY_OPEN';
  static const String yaCerrado = 'ALREADY_CLOSED';
  static const String comandoDesconocido = 'ERROR:UNKNOWN_COMMAND';
}

// Comandos para enviar al candado
class ComandosCandado {
  static const String abrir = 'OPEN';
  static const String cerrar = 'CLOSE';
  static const String toggle = 'TOGGLE';
  static const String estado = 'STATUS';
  static const String obtenerClave = 'GETKEY';
}
