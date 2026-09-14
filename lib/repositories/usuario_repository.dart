import 'package:ekeyless/models/usuario_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class UsuarioRepository {
  Future<UsuarioModel?> obtenerPorId(String id);
  Future<UsuarioModel?> obtenerPorEmail(String email);
  Future<List<UsuarioModel>> obtenerTodos();
  Future<List<UsuarioModel>> obtenerAmigos(String userId);
  Future<bool> emailDisponible(String email);
  Future<bool> nombreUsuarioDisponible(String nombreUsuario);
  Future<void> crear(UsuarioModel usuario);
  Future<void> actualizar(UsuarioModel usuario);
}

class SupabaseUsuarioRepository implements UsuarioRepository {
  SupabaseUsuarioRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<UsuarioModel?> obtenerPorId(String id) async {
    final data =
        await _client.from('usuarios').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return UsuarioModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<UsuarioModel?> obtenerPorEmail(String email) async {
    final data =
        await _client
            .from('usuarios')
            .select()
            .eq('email', email)
            .maybeSingle();
    if (data == null) return null;
    return UsuarioModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<UsuarioModel>> obtenerTodos() async {
    final data = await _client.from('usuarios').select().order('nombreUsuario');
    return data
        .map((row) => UsuarioModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<List<UsuarioModel>> obtenerAmigos(String userId) async {
    final user = await obtenerPorId(userId);
    if (user == null || user.amigos.isEmpty) return [];

    final data = await _client
        .from('usuarios')
        .select()
        .inFilter('id', user.amigos);
    return data
        .map((row) => UsuarioModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<bool> emailDisponible(String email) async {
    final data =
        await _client
            .from('usuarios')
            .select('id')
            .eq('email', email)
            .maybeSingle();
    return data == null;
  }

  @override
  Future<bool> nombreUsuarioDisponible(String nombreUsuario) async {
    final resultado = await _client.rpc(
      'nombre_usuario_disponible',
      params: {'p_nombre_usuario': nombreUsuario.trim()},
    );

    return resultado == true;
  }

  @override
  Future<void> crear(UsuarioModel usuario) async {
    await _client.from('usuarios').upsert(usuario.toJson());
  }

  @override
  Future<void> actualizar(UsuarioModel usuario) async {
    await _client
        .from('usuarios')
        .update(usuario.toJson())
        .eq('id', usuario.id);
  }
}
