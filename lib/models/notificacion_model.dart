class NotificacionModel {
  final String id;
  final String emisorId;
  final String receptorId;
  final String titulo;
  final String cuerpo;
  final bool leido;
  final TipoNotificacion tipo;
  final DateTime fechaCreacion;

  NotificacionModel._({
    required this.id,
    required this.emisorId,
    required this.receptorId,
    required this.titulo,
    required this.cuerpo,
    this.leido = false,
    required this.tipo,
    required this.fechaCreacion,
  });

  // Factory constructor que auto-completa título y cuerpo
  factory NotificacionModel.crear({
    required String id,
    required String emisorId,
    required String receptorId,
    required TipoNotificacion tipo,
    required String nombreEmisor, // Solo necesario para el cuerpo
    bool leido = false,
    DateTime? fechaCreacion,
  }) {
    return NotificacionModel._(
      id: id,
      emisorId: emisorId,
      receptorId: receptorId,
      titulo: _generarTitulo(tipo),
      cuerpo: _generarCuerpo(tipo, nombreEmisor),
      leido: leido,
      tipo: tipo,
      fechaCreacion: fechaCreacion ?? DateTime.now(),
    );
  }

  // Método estático para generar título automático
  static String _generarTitulo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.amigo:
        return 'Nueva solicitud de amistad';
      case TipoNotificacion.acceso:
        return 'Nuevo acceso detectado';
      case TipoNotificacion.sistema:
        return 'Notificación del sistema';
    }
  }

  // Método estático para generar cuerpo automático
  static String _generarCuerpo(TipoNotificacion tipo, String nombreEmisor) {
    switch (tipo) {
      case TipoNotificacion.amigo:
        return '$nombreEmisor te ha enviado una solicitud de amistad. ¡Revisa tu lista de solicitudes pendientes!';
      case TipoNotificacion.acceso:
        return 'Se ha detectado un nuevo acceso a tu cuenta. Si no fuiste tú, revisa la seguridad de tu cuenta.';
      case TipoNotificacion.sistema:
        return 'Tienes una nueva notificación del sistema. Revisa los detalles en la aplicación.';
    }
  }

  Map<String, dynamic> toJson() {
    return toSupabaseJson();
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id.isEmpty ? null : id,
      'emisorId': emisorId,
      'receptorId': receptorId,
      'titulo': titulo,
      'cuerpo': cuerpo,
      'leido': leido,
      'tipo': tipo.name,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  static DateTime _parseFecha(dynamic value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel._(
      id: json['id'] ?? '',
      emisorId: json['emisorId'] ?? '',
      receptorId: json['receptorId'] ?? '',
      titulo: json['titulo'] ?? '',
      cuerpo: json['cuerpo'] ?? '',
      leido: json['leido'] ?? false,
      tipo: TipoNotificacion.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoNotificacion.amigo,
      ),
      fechaCreacion: _parseFecha(json['fechaCreacion']),
    );
  }

  NotificacionModel copyWith({
    String? id,
    String? emisorId,
    String? receptorId,
    String? titulo,
    String? cuerpo,
    bool? leido,
    TipoNotificacion? tipo,
    DateTime? fechaCreacion,
  }) {
    return NotificacionModel._(
      id: id ?? this.id,
      emisorId: emisorId ?? this.emisorId,
      receptorId: receptorId ?? this.receptorId,
      titulo: titulo ?? this.titulo,
      cuerpo: cuerpo ?? this.cuerpo,
      leido: leido ?? this.leido,
      tipo: tipo ?? this.tipo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Método para marcar como leída
  NotificacionModel marcarComoLeida() {
    return copyWith(leido: true);
  }

  // Método para verificar si es una notificación reciente (últimas 24 horas)
  bool get esReciente {
    final diferencia = DateTime.now().difference(fechaCreacion);
    return diferencia.inHours < 24;
  }

  // Método para obtener tiempo transcurrido formateado
  String get tiempoTranscurrido {
    final diferencia = DateTime.now().difference(fechaCreacion);

    if (diferencia.inDays > 0) {
      return 'hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  @override
  String toString() {
    return 'NotificacionModel(id: $id, emisorId: $emisorId, receptorId: $receptorId, titulo: $titulo, leido: $leido, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificacionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum para los tipos de notificaciones
enum TipoNotificacion {
  amigo,
  acceso,
  sistema,
  // Puedes agregar más tipos según necesites
}

// Extensión para obtener información adicional del tipo
extension TipoNotificacionExtension on TipoNotificacion {
  String get displayName {
    switch (this) {
      case TipoNotificacion.amigo:
        return 'Solicitud de Amistad';
      case TipoNotificacion.acceso:
        return 'Acceso al Sistema';
      case TipoNotificacion.sistema:
        return 'Notificación del Sistema';
    }
  }

  String get icono {
    switch (this) {
      case TipoNotificacion.amigo:
        return '👥';
      case TipoNotificacion.acceso:
        return '🔐';
      case TipoNotificacion.sistema:
        return '⚙️';
    }
  }
}
