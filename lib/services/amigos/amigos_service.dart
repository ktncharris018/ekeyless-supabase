import 'package:ekeyless/models/notificacion_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/repositories/notificacion_repository.dart';
import 'package:ekeyless/repositories/usuario_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AmigosService {
  AmigosService({
    SupabaseClient? client,
    UsuarioRepository? usuarios,
    NotificacionRepository? notificaciones,
  })  : _client = client ?? Supabase.instance.client,
        _usuarios = usuarios ?? SupabaseUsuarioRepository(client: client),
        _notificaciones =
            notificaciones ?? SupabaseNotificacionRepository(client: client);

  final SupabaseClient _client;
  final UsuarioRepository _usuarios;
  final NotificacionRepository _notificaciones;

  Future<UsuarioModel?> getCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    return _usuarios.obtenerPorId(uid);
  }

  Future<List<UsuarioModel>> searchUsersByName(String query) async {
    final data = await _client
        .from('usuarios')
        .select()
        .ilike('nombreUsuario', '$query%')
        .order('nombreUsuario');
    return data
        .map((row) => UsuarioModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<UsuarioModel>> obtenerTodosLosUsuarios() => _usuarios.obtenerTodos();

  Future<void> enviarSolicitudAmistad(String receptorId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');
    await _client.rpc('enviar_solicitud_amistad', params: {'p_receptor_id': receptorId});

    final emisor = await _usuarios.obtenerPorId(uid);
    if (emisor != null) {
      // The SQL function creates the notification atomically; this local model
      // construction documents the business rule while keeping UI behavior intact.
      NotificacionModel.crear(
        id: '',
        emisorId: uid,
        receptorId: receptorId,
        tipo: TipoNotificacion.amigo,
        nombreEmisor: emisor.nombreUsuario,
      );
    }
  }

  Future<void> aceptarSolicitudAmistad(String emisorId) async {
    await _client.rpc('aceptar_solicitud_amistad', params: {'p_emisor_id': emisorId});
  }

  Future<void> cancelarSolicitudAmistad(String receptorId) async {
    await _client.rpc('cancelar_solicitud_amistad', params: {'p_receptor_id': receptorId});
  }
}
