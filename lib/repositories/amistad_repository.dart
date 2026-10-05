import 'package:ekeyless/models/usuario_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AmistadRepository {
  Future<List<UsuarioModel>> buscarUsuariosPorNombre(String query);
  Future<void> enviarSolicitudAmistad(String receptorId);
  Future<void> aceptarSolicitudAmistad(String emisorId);
  Future<void> cancelarSolicitudAmistad(String receptorId);
}

class SupabaseAmistadRepository implements AmistadRepository {
  SupabaseAmistadRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<UsuarioModel>> buscarUsuariosPorNombre(String query) async {
    final data = await _client
        .from('usuarios')
        .select()
        .ilike('nombreUsuario', '$query%')
        .order('nombreUsuario');

    return data
        .map((row) => UsuarioModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<void> enviarSolicitudAmistad(String receptorId) async {
    await _client.rpc(
      'enviar_solicitud_amistad',
      params: {'p_receptor_id': receptorId},
    );
  }

  @override
  Future<void> aceptarSolicitudAmistad(String emisorId) async {
    await _client.rpc(
      'aceptar_solicitud_amistad',
      params: {'p_emisor_id': emisorId},
    );
  }

  @override
  Future<void> cancelarSolicitudAmistad(String receptorId) async {
    await _client.rpc(
      'cancelar_solicitud_amistad',
      params: {'p_receptor_id': receptorId},
    );
  }
}
