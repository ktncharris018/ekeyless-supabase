import 'package:ekeyless/models/notificacion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificacionRepository {
  Future<void> crear(NotificacionModel notificacion);
  Stream<List<NotificacionModel>> streamPorReceptor(String receptorId);
  Future<void> marcarComoLeida(String id);
  Future<void> eliminar(String id);
}

class SupabaseNotificacionRepository implements NotificacionRepository {
  SupabaseNotificacionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<void> crear(NotificacionModel notificacion) async {
    final row = notificacion.toSupabaseJson();
    if (notificacion.id.isEmpty) row.remove('id');
    await _client.from('notificaciones').insert(row);
  }

  @override
  Stream<List<NotificacionModel>> streamPorReceptor(String receptorId) {
    return _client
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .eq('receptorId', receptorId)
        .order('fechaCreacion', ascending: false)
        .map((rows) => rows
            .map((row) => NotificacionModel.fromJson(
                  Map<String, dynamic>.from(row),
                ))
            .toList());
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    await _client.from('notificaciones').update({'leido': true}).eq('id', id);
  }

  @override
  Future<void> eliminar(String id) async {
    await _client.from('notificaciones').delete().eq('id', id);
  }
}
