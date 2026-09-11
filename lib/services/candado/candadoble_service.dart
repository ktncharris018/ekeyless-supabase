import 'dart:async';
import 'dart:convert';

import 'package:ekeyless/repositories/candado_repository.dart';
import 'package:ekeyless/repositories/usuario_repository.dart';
import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CandadoBLEService {
  static final CandadoBLEService _instance = CandadoBLEService._internal();
  factory CandadoBLEService() => _instance;
  CandadoBLEService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  final CandadoRepository _candadoRepository = SupabaseCandadoRepository();
  final UsuarioRepository _usuarioRepository = SupabaseUsuarioRepository();

  User? get currentUser => _client.auth.currentUser;

  // Streams para notificaciones
  StreamSubscription<List<int>>? _statusSubscription;
  StreamSubscription<List<int>>? _keySubscription;

  /// Constantes de configuración BLE
  static const String _serviceUUID = '12345678';
  static const String _statusCharacteristicUUID = 'ad';
  static const String _commandCharacteristicUUID = 'ac';
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _scanTimeout = Duration(seconds: 4);

  /// Permisos necesarios para BLE
  static const List<Permission> _requiredPermissions = [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
    Permission.location,
    Permission.nearbyWifiDevices,
  ];

  // ==================== GESTIÓN DE CANDADOS ====================

  /// Obtiene todos los candados del usuario actual
  Future<List<CandadoModel>> obtenerCandadosUsuario() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final candados = await _candadoRepository.obtenerTodos();
      return candados.where((candado) => candado.tieneAcceso(user.id)).toList();
    } catch (e) {
      throw Exception('Error al cargar candados: $e');
    }
  }

  /// Obtiene los nombres de candados ya registrados
  Future<Set<String>> obtenerCandadosRegistrados() async {
    try {
      return await _candadoRepository.obtenerNombresRegistrados();
    } catch (e) {
      throw Exception('Error al obtener candados registrados: $e');
    }
  }

  /// Guarda un nuevo candado en Supabase
  Future<void> guardarCandado(CandadoModel candado) async {
    try {
      await _candadoRepository.guardar(candado);
    } catch (e) {
      throw Exception('Error al guardar candado: $e');
    }
  }

  /// Actualiza un candado existente
  Future<void> actualizarCandado(CandadoModel candado) async {
    try {
      await _candadoRepository.actualizar(candado);
    } catch (e) {
      throw Exception('Error al actualizar candado: $e');
    }
  }

  /// Obtiene un candado por su key
  Future<CandadoModel?> obtenerCandadoPorKey(String key) async {
    try {
      return await _candadoRepository.obtenerPorKey(key);
    } catch (e) {
      throw Exception('Error al obtener candado: $e');
    }
  }

  // ==================== GESTIÓN DE USUARIOS ====================

  /// Obtiene la lista de amigos del usuario actual
  Future<List<UsuarioModel>> obtenerAmigos() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      return await _usuarioRepository.obtenerAmigos(user.id);
    } catch (e) {
      throw Exception('Error al cargar amigos: $e');
    }
  }

  /// Obtiene un usuario por su ID
  Future<UsuarioModel?> obtenerUsuarioPorId(String id) async {
    try {
      return await _usuarioRepository.obtenerPorId(id);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // ==================== GESTIÓN BLUETOOTH ====================

  /// Verifica si Bluetooth está soportado
  Future<bool> esBluetoothSoportado() async {
    return await FlutterBluePlus.isSupported;
  }

  /// Verifica si Bluetooth está encendido
  Future<bool> esBluetoothEncendido() async {
    final estado = await FlutterBluePlus.adapterState.first;
    return estado == BluetoothAdapterState.on;
  }

  /// Enciende Bluetooth
  Future<void> encenderBluetooth() async {
    await FlutterBluePlus.turnOn();
  }

  /// Solicita permisos necesarios
  Future<bool> solicitarPermisos() async {
    for (final permiso in _requiredPermissions) {
      if (await permiso.isDenied || await permiso.isPermanentlyDenied) {
        final status = await permiso.request();
        if (!status.isGranted) return false;
      }
    }
    return true;
  }

  /// Verifica y solicita activación del GPS
  Future<bool> verificarGPS() async {
    final habilitado = await Geolocator.isLocationServiceEnabled();
    if (!habilitado) {
      await Geolocator.openLocationSettings();
      return await Geolocator.isLocationServiceEnabled();
    }
    return true;
  }

  /// Escanea dispositivos BLE
  Stream<List<BluetoothDevice>> escanearDispositivos({
    Duration timeout = _scanTimeout,
    String filtroNombre = 'lock',
  }) async* {
    final dispositivos = <BluetoothDevice>[];
    
    await FlutterBluePlus.startScan(timeout: timeout);
    
    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        final nombre = result.device.platformName.toLowerCase();
        if (nombre.startsWith(filtroNombre.toLowerCase()) &&
            !dispositivos.any((d) => d.remoteId == result.device.remoteId)) {
          dispositivos.add(result.device);
        }
      }
      yield List.from(dispositivos);
    }
  }

  /// Detiene el escaneo
  Future<void> detenerEscaneo() async {
    await FlutterBluePlus.stopScan();
  }

  /// Conecta a un dispositivo BLE
  Future<void> conectarDispositivo(BluetoothDevice dispositivo) async {
    try {
      await dispositivo.connect(timeout: _connectionTimeout);
    } catch (e) {
      throw Exception('Error al conectar dispositivo: $e');
    }
  }

  /// Desconecta un dispositivo BLE
  Future<void> desconectarDispositivo(BluetoothDevice dispositivo) async {
    try {
      await dispositivo.disconnect();
      _statusSubscription?.cancel();
      _keySubscription?.cancel();
    } catch (e) {
      throw Exception('Error al desconectar dispositivo: $e');
    }
  }

  /// Descubre servicios del dispositivo
  Future<List<BluetoothService>> descubrirServicios(BluetoothDevice dispositivo) async {
    try {
      return await dispositivo.discoverServices();
    } catch (e) {
      throw Exception('Error al descubrir servicios: $e');
    }
  }

  /// Envía comando al candado
  Future<void> enviarComando(BluetoothDevice dispositivo, String comando) async {
    try {
      final servicios = await descubrirServicios(dispositivo);
      final servicio = servicios.firstWhere(
        (s) => s.uuid.toString().contains(_serviceUUID),
      );
      final caracteristica = servicio.characteristics.firstWhere(
        (c) => c.uuid.toString().contains(_commandCharacteristicUUID),
      );
      
      await caracteristica.write(utf8.encode(comando));
    } catch (e) {
      throw Exception('Error al enviar comando: $e');
    }
  }

  /// Suscribe a notificaciones de estado del candado
  Stream<String> suscribirEstado(BluetoothDevice dispositivo) async* {
    try {
      final servicios = await descubrirServicios(dispositivo);
      final servicio = servicios.firstWhere(
        (s) => s.uuid.toString().contains(_serviceUUID),
      );
      final caracteristica = servicio.characteristics.firstWhere(
        (c) => c.uuid.toString().contains(_statusCharacteristicUUID),
      );

      await caracteristica.setNotifyValue(true);
      
      await for (final bytes in caracteristica.onValueReceived) {
        final mensaje = utf8.decode(bytes).trim();
        yield mensaje;
      }
    } catch (e) {
      throw Exception('Error al suscribir estado: $e');
    }
  }

  // ==================== GESTIÓN DE ACCESO ====================

  /// Comparte acceso a un candado
  Future<void> compartirAcceso({
    required CandadoModel candado,
    required String usuarioId,
    required bool esTemporal,
    DateTime? fechaExpiracion,
  }) async {
    try {
      final candadoActual = await obtenerCandadoPorKey(candado.key);
      if (candadoActual == null) {
        throw Exception('El candado ya no existe');
      }

      if (esTemporal) {
        if (fechaExpiracion == null || fechaExpiracion.isBefore(DateTime.now())) {
          throw Exception('Fecha de expiración inválida');
        }
        
        final invitadosTemporales = List<InvitadoTemporal>.from(candadoActual.invitadosTemporales);
        invitadosTemporales.add(InvitadoTemporal(
          usuarioId: usuarioId,
          fechaExpiracion: fechaExpiracion,
        ));
        
        final candadoActualizado = candadoActual.copyWith(
          invitadosTemporales: invitadosTemporales,
        );
        await actualizarCandado(candadoActualizado);
      } else {
        final invitadosPermanentes = List<String>.from(candadoActual.invitadosPermanentes);
        if (!invitadosPermanentes.contains(usuarioId)) {
          invitadosPermanentes.add(usuarioId);
          
          final candadoActualizado = candadoActual.copyWith(
            invitadosPermanentes: invitadosPermanentes,
          );
          await actualizarCandado(candadoActualizado);
        } else {
          throw Exception('El usuario ya tiene acceso permanente');
        }
      }
    } catch (e) {
      throw Exception('Error al compartir acceso: $e');
    }
  }

  /// Valida acceso temporal
  bool validarAccesoTemporal(CandadoModel candado, String usuarioId) {
    final invitado = candado.invitadosTemporales.firstWhere(
      (inv) => inv.usuarioId == usuarioId,
      orElse: () => InvitadoTemporal(usuarioId: '', fechaExpiracion: DateTime.now()),
    );
    
    return invitado.usuarioId.isNotEmpty && 
           invitado.fechaExpiracion.isAfter(DateTime.now());
  }

  // ==================== LIMPIEZA ====================

  /// Limpia recursos
  void dispose() {
    _statusSubscription?.cancel();
    _keySubscription?.cancel();
  }
}