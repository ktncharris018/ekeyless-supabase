import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/repositories/candado_repository.dart';
import 'package:ekeyless/repositories/usuario_repository.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:ekeyless/services/candado/location_service.dart';
import 'package:ekeyless/services/candado/permission_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CandadoBLEService {
  CandadoBLEService({
    SupabaseClient? client,
    CandadoRepository? candadoRepository,
    UsuarioRepository? usuarioRepository,
    BleLockGateway? bleGateway,
    IPermissionService? permissionService,
    ILocationService? locationService,
  })  : _client = client ?? Supabase.instance.client,
        _candadoRepository =
            candadoRepository ?? SupabaseCandadoRepository(client: client),
        _usuarioRepository =
            usuarioRepository ?? SupabaseUsuarioRepository(client: client),
        _bleGateway = bleGateway ?? FlutterBluetoothService(),
        _permissionService = permissionService ?? PermissionService(),
        _locationService = locationService ?? LocationService();

  final SupabaseClient _client;
  final CandadoRepository _candadoRepository;
  final UsuarioRepository _usuarioRepository;
  final BleLockGateway _bleGateway;
  final IPermissionService _permissionService;
  final ILocationService _locationService;

  User? get currentUser => _client.auth.currentUser;

  Future<List<CandadoModel>> obtenerCandadosUsuario() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final candados = await _candadoRepository.obtenerTodos();
      return candados.where((c) => c.tieneAcceso(user.id)).toList();
    } catch (e) {
      throw Exception('Error al cargar candados: $e');
    }
  }

  Future<Set<String>> obtenerCandadosRegistrados() async {
    try {
      return await _candadoRepository.obtenerNombresRegistrados();
    } catch (e) {
      throw Exception('Error al obtener candados registrados: $e');
    }
  }

  Future<void> guardarCandado(CandadoModel candado) async {
    try {
      await _candadoRepository.guardar(candado);
    } catch (e) {
      throw Exception('Error al guardar candado: $e');
    }
  }

  Future<void> actualizarCandado(CandadoModel candado) async {
    try {
      await _candadoRepository.actualizar(candado);
    } catch (e) {
      throw Exception('Error al actualizar candado: $e');
    }
  }

  Future<CandadoModel?> obtenerCandadoPorKey(String key) async {
    try {
      return await _candadoRepository.obtenerPorKey(key);
    } catch (e) {
      throw Exception('Error al obtener candado: $e');
    }
  }

  Future<List<UsuarioModel>> obtenerAmigos() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      return await _usuarioRepository.obtenerAmigos(user.id);
    } catch (e) {
      throw Exception('Error al cargar amigos: $e');
    }
  }

  Future<UsuarioModel?> obtenerUsuarioPorId(String id) async {
    try {
      return await _usuarioRepository.obtenerPorId(id);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<bool> esBluetoothSoportado() => _bleGateway.esBluetoothSoportado();

  Future<bool> esBluetoothEncendido() => _bleGateway.esBluetoothEncendido();

  Future<void> encenderBluetooth() => _bleGateway.encenderBluetooth();

  Future<bool> solicitarPermisos() =>
      _permissionService.solicitarPermisosBluetooth();

  Future<bool> verificarGPS() => _locationService.verificarGPS();

  Stream<List<BluetoothDevice>> escanearDispositivos({
    Duration timeout = const Duration(seconds: 4),
    String filtroNombre = 'lock',
  }) => _bleGateway.escanearDispositivos(
        timeout: timeout,
        filtroNombre: filtroNombre,
      );

  Future<void> detenerEscaneo() => _bleGateway.detenerEscaneo();

  Future<void> conectarDispositivo(BluetoothDevice dispositivo) =>
      _bleGateway.conectarDispositivo(dispositivo);

  Future<void> desconectarDispositivo(BluetoothDevice dispositivo) =>
      _bleGateway.desconectarDispositivo(dispositivo);

  Future<List<BluetoothService>> descubrirServicios(
    BluetoothDevice dispositivo,
  ) => dispositivo.discoverServices();

  Future<void> enviarComando(BluetoothDevice dispositivo, String comando) =>
      _bleGateway.enviarComando(dispositivo, comando);

  Stream<String> suscribirEstado(BluetoothDevice dispositivo) =>
      _bleGateway.suscribirEstado(dispositivo);

  Future<void> compartirAcceso({
    required CandadoModel candado,
    required String usuarioId,
    required bool esTemporal,
    DateTime? fechaExpiracion,
  }) async {
    try {
      final candadoActual = await obtenerCandadoPorKey(candado.key);
      if (candadoActual == null) throw Exception('El candado ya no existe');

      if (esTemporal) {
        if (fechaExpiracion == null ||
            fechaExpiracion.isBefore(DateTime.now())) {
          throw Exception('Fecha de expiración inválida');
        }

        final invitadosTemporales =
            List<InvitadoTemporal>.from(candadoActual.invitadosTemporales)
              ..add(
                InvitadoTemporal(
                  usuarioId: usuarioId,
                  fechaExpiracion: fechaExpiracion,
                ),
              );

        await actualizarCandado(
          candadoActual.copyWith(
            invitadosTemporales: invitadosTemporales,
          ),
        );
      } else {
        final invitadosPermanentes =
            List<String>.from(candadoActual.invitadosPermanentes);
        if (invitadosPermanentes.contains(usuarioId)) {
          throw Exception('El usuario ya tiene acceso permanente');
        }

        invitadosPermanentes.add(usuarioId);
        await actualizarCandado(
          candadoActual.copyWith(
            invitadosPermanentes: invitadosPermanentes,
          ),
        );
      }
    } catch (e) {
      throw Exception('Error al compartir acceso: $e');
    }
  }

  bool validarAccesoTemporal(CandadoModel candado, String usuarioId) {
    final invitado = candado.invitadosTemporales.firstWhere(
      (inv) => inv.usuarioId == usuarioId,
      orElse: () => InvitadoTemporal(
        usuarioId: '',
        fechaExpiracion: DateTime.now(),
      ),
    );

    return invitado.usuarioId.isNotEmpty &&
        invitado.fechaExpiracion.isAfter(DateTime.now());
  }

  void dispose() => _bleGateway.dispose();
}
