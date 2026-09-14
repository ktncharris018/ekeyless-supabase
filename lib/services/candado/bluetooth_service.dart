import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'location_service.dart';
import 'permission_service.dart';

abstract class IBleLockGateway {
  Future<bool> esBluetoothSoportado();
  Future<bool> esBluetoothEncendido();
  Future<void> encenderBluetooth();
  Future<bool> solicitarPermisos();
  Future<bool> verificarGPS();
  Stream<List<BluetoothDevice>> escanearDispositivos({
    Duration timeout,
    String filtroNombre,
  });
  Future<void> detenerEscaneo();
  Future<void> conectarDispositivo(BluetoothDevice dispositivo);
  Future<void> desconectarDispositivo(BluetoothDevice dispositivo);
  Future<void> enviarComando(BluetoothDevice dispositivo, String comando);
  Stream<String> suscribirEstado(BluetoothDevice dispositivo);
  void dispose();
}

class FlutterBluetoothService implements IBleLockGateway {
  FlutterBluetoothService({
    IPermissionService? permissionService,
    ILocationService? locationService,
  })  : _permissionService = permissionService ?? PermissionService(),
        _locationService = locationService ?? LocationService();

  final IPermissionService _permissionService;
  final ILocationService _locationService;
  static const String _serviceUUID = '12345678';
  static const String _statusCharacteristicUUID = 'ad';
  static const String _commandCharacteristicUUID = 'ac';
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _scanTimeout = Duration(seconds: 4);

  @override
  Future<bool> esBluetoothSoportado() => FlutterBluePlus.isSupported;

  @override
  Future<bool> esBluetoothEncendido() async {
    final estado = await FlutterBluePlus.adapterState.first;
    return estado == BluetoothAdapterState.on;
  }

  @override
  Future<void> encenderBluetooth() => FlutterBluePlus.turnOn();

  @override
  Future<bool> solicitarPermisos() =>
      _permissionService.solicitarPermisosBluetooth();

  @override
  Future<bool> verificarGPS() => _locationService.verificarGPS();

  @override
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
      yield List<BluetoothDevice>.from(dispositivos);
    }
  }

  @override
  Future<void> detenerEscaneo() => FlutterBluePlus.stopScan();

  @override
  Future<void> conectarDispositivo(BluetoothDevice dispositivo) async {
    try {
      await dispositivo.connect(timeout: _connectionTimeout);
    } catch (e) {
      throw Exception('Error al conectar dispositivo: $e');
    }
  }

  @override
  Future<void> desconectarDispositivo(BluetoothDevice dispositivo) async {
    try {
      await dispositivo.disconnect();
    } catch (e) {
      throw Exception('Error al desconectar dispositivo: $e');
    }
  }

  @override
  Future<void> enviarComando(
    BluetoothDevice dispositivo,
    String comando,
  ) async {
    try {
      final servicios = await dispositivo.discoverServices();
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

  @override
  Stream<String> suscribirEstado(BluetoothDevice dispositivo) async* {
    try {
      final servicios = await dispositivo.discoverServices();
      final servicio = servicios.firstWhere(
        (s) => s.uuid.toString().contains(_serviceUUID),
      );
      final caracteristica = servicio.characteristics.firstWhere(
        (c) => c.uuid.toString().contains(_statusCharacteristicUUID),
      );

      await caracteristica.setNotifyValue(true);
      await for (final bytes in caracteristica.onValueReceived) {
        yield utf8.decode(bytes).trim();
      }
    } catch (e) {
      throw Exception('Error al suscribir estado: $e');
    }
  }

  @override
  void dispose() {}
}
