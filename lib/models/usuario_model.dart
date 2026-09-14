class UsuarioModel {
  final String id;
  final String imagenPerfil;
  final String nombreUsuario;
  final String email;
  final bool authGoogle;
  List<String> amigos;
  List<String> solicitudesRecibidas;
  List<String> solicitudesEnviadas;

  UsuarioModel({
    required this.id,
    required this.imagenPerfil,
    required this.nombreUsuario,
    required this.authGoogle,
    required this.email,
    this.amigos = const [],
    this.solicitudesRecibidas = const [],
    this.solicitudesEnviadas = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagenPerfil': imagenPerfil,
      'nombreUsuario': nombreUsuario,
      'email': email,
      'authGoogle': authGoogle,
      'amigos': amigos,
      'solicitudesRecibidas': solicitudesRecibidas,
      'solicitudesEnviadas': solicitudesEnviadas,
    };
  }

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] ?? '',
      imagenPerfil: json['imagenPerfil'] ?? '',
      nombreUsuario: json['nombreUsuario'] ?? '',
      email: json['email'] ?? '',
      authGoogle: json['authGoogle'] ?? false,
      amigos: List<String>.from(json['amigos'] ?? []),
      solicitudesRecibidas: List<String>.from(
        json['solicitudesRecibidas'] ?? [],
      ),
      solicitudesEnviadas: List<String>.from(json['solicitudesEnviadas'] ?? []),
    );
  }

  UsuarioModel copyWith({
    String? id,
    String? imagenPerfil,
    String? nombreUsuario,
    bool? authGoogle,
    String? email,
    List<String>? amigos,
    List<String>? solicitudesRecibidas,
    List<String>? solicitudesEnviadas,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      authGoogle: authGoogle ?? this.authGoogle,
      email: email ?? this.email,
      amigos: amigos ?? this.amigos,
      solicitudesRecibidas: solicitudesRecibidas ?? this.solicitudesRecibidas,
      solicitudesEnviadas: solicitudesEnviadas ?? this.solicitudesEnviadas,
    );
  }
}
