import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilAccesoHistorial {
  final String? perfilId;
  final String propietarioId;
  final String operacion;
  final Map<String, dynamic> detalles;

  const PerfilAccesoHistorial({
    required this.perfilId,
    required this.propietarioId,
    required this.operacion,
    required this.detalles,
  });

  Map<String, dynamic> toJson() {
    return {
      'perfil_id': perfilId,
      'propietario_id': propietarioId,
      'operacion': operacion,
      'detalles': detalles,
    };
  }
}

abstract class PerfilAccesoRepository {
  Future<List<PerfilAcceso>> obtenerPorCandado(String candadoKey);
  Future<PerfilAcceso> guardar(PerfilAcceso perfil);
  Future<void> actualizar(PerfilAcceso perfil);
  Future<void> eliminar(String perfilId);
  Future<void> registrarHistorial(PerfilAccesoHistorial historial);
}

class SupabasePerfilAccesoRepository implements PerfilAccesoRepository {
  SupabasePerfilAccesoRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<PerfilAcceso>> obtenerPorCandado(String candadoKey) async {
    final data = await _client
        .from('perfiles_acceso')
        .select()
        .eq('candado_key', candadoKey)
        .order('nombre');

    return data
        .map((row) => PerfilAcceso.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<PerfilAcceso> guardar(PerfilAcceso perfil) async {
    final data = await _client
        .from('perfiles_acceso')
        .insert(perfil.toJson())
        .select()
        .single();
    return PerfilAcceso.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> actualizar(PerfilAcceso perfil) async {
    final id = perfil.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('No se puede actualizar un perfil sin id');
    }

    await _client.from('perfiles_acceso').update(perfil.toJson()).eq('id', id);
  }

  @override
  Future<void> eliminar(String perfilId) async {
    await _client.from('perfiles_acceso').delete().eq('id', perfilId);
  }

  @override
  Future<void> registrarHistorial(PerfilAccesoHistorial historial) async {
    await _client.from('perfiles_acceso_historial').insert(historial.toJson());
  }
}
