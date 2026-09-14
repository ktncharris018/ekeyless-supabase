import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/repositories/notificacion_repository.dart';
import 'package:ekeyless/repositories/amistad_repository.dart';
import 'package:ekeyless/repositories/usuario_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AmigosService {
  AmigosService({
    SupabaseClient? client,
    UsuarioRepository? usuarios,
    AmistadRepository? amistades,
    NotificacionRepository? notificaciones,
  })  : _client = client ?? Supabase.instance.client,
        _usuarios = usuarios ?? SupabaseUsuarioRepository(client: client),
        _amistades = amistades ?? SupabaseAmistadRepository(client: client),
        _notificaciones =
            notificaciones ?? SupabaseNotificacionRepository(client: client);

  final SupabaseClient _client;
  final UsuarioRepository _usuarios;
  final AmistadRepository _amistades;
  final NotificacionRepository _notificaciones;

  Future<UsuarioModel?> getCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    return _usuarios.obtenerPorId(uid);
  }

  Future<List<UsuarioModel>> searchUsersByName(String query) =>
      _amistades.buscarUsuariosPorNombre(query);

  Future<List<UsuarioModel>> obtenerTodosLosUsuarios() => _usuarios.obtenerTodos();

  Future<void> enviarSolicitudAmistad(String receptorId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');
    await _amistades.enviarSolicitudAmistad(receptorId);

    // La función SQL mantiene la solicitud y su notificación de forma atómica.
    await _usuarios.obtenerPorId(uid);
  }

  Future<void> aceptarSolicitudAmistad(String emisorId) =>
      _amistades.aceptarSolicitudAmistad(emisorId);

  Future<void> cancelarSolicitudAmistad(String receptorId) =>
      _amistades.cancelarSolicitudAmistad(receptorId);

}
