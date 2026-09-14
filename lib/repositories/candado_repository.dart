import 'package:ekeyless/models/candado_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CandadoRepository {
  Future<List<CandadoModel>> obtenerTodos();
  Future<CandadoModel?> obtenerPorKey(String key);
  Future<Set<String>> obtenerNombresRegistrados();
  Future<void> guardar(CandadoModel candado);
  Future<void> actualizar(CandadoModel candado);
}

class SupabaseCandadoRepository implements CandadoRepository {
  SupabaseCandadoRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<CandadoModel>> obtenerTodos() async {
    final data = await _client.from('candados').select();
    return data
        .map((row) => CandadoModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<CandadoModel?> obtenerPorKey(String key) async {
    final data = await _client.from('candados').select().eq('key', key).maybeSingle();
    if (data == null) return null;
    return CandadoModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<Set<String>> obtenerNombresRegistrados() async {
    final data = await _client.from('candados').select('nombre');
    return data
        .map((row) => (row['nombre'] ?? '').toString().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  @override
  Future<void> guardar(CandadoModel candado) async {
    await _client.from('candados').upsert(candado.toJson());
  }

  @override
  Future<void> actualizar(CandadoModel candado) async {
    await _client.from('candados').update(candado.toJson()).eq('key', candado.key);
  }
}
