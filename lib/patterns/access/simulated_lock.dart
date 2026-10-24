import 'dart:async';

import 'communication_factory.dart';

/// Dispositivo en memoria que representa el candado de demostración.
/// Mantiene el estado entre pantallas durante la ejecución de la aplicación.
class SimulatedLockDevice implements LockDevice {
  SimulatedLockDevice._();

  static final SimulatedLockDevice instance = SimulatedLockDevice._();

  static const String deviceId = 'simulated-ekeyless-lock-001';
  static const String deviceName = 'Candado de demostración';
  static const String lockKey = 'DEMO-EKEYLESS-0001';

  final StreamController<String> _messages =
      StreamController<String>.broadcast(sync: true);
  bool _isOpen = false;

  @override
  String get id => deviceId;

  @override
  String get nombre => deviceName;

  bool get estaAbierto => _isOpen;

  Stream<String> get mensajes => _messages.stream;

  void publicarMensaje(String mensaje) {
    _messages.add(mensaje);
  }

  void abrir() {
    _isOpen = true;
    publicarMensaje('OPENED');
  }

  void cerrar() {
    _isOpen = false;
    publicarMensaje('CLOSED');
  }

  String obtenerEstado() => _isOpen ? 'STATUS:OPEN' : 'STATUS:CLOSED';
}

/// Simula el protocolo de comandos del firmware del candado BLE.
/// Usa OPEN, CLOSE, STATUS y GETKEY, los mismos comandos de la app.
class SimulatedLockCommandChannel implements LockCommandChannel {
  SimulatedLockCommandChannel(this._device);

  final SimulatedLockDevice _device;
  static const Duration _responseDelay = Duration(milliseconds: 300);

  @override
  Future<void> enviar(LockDevice device, String comando) async {
    if (device is! SimulatedLockDevice || device.id != _device.id) {
      throw ArgumentError('El dispositivo no pertenece al candado simulado.');
    }

    // Añade una pequeña latencia para aproximarse a una respuesta BLE real.
    await Future<void>.delayed(_responseDelay);

    switch (comando.trim().toUpperCase()) {
      case 'GETKEY':
        _device.publicarMensaje('KEY:${SimulatedLockDevice.lockKey}');
        break;
      case 'STATUS':
        _device.publicarMensaje(_device.obtenerEstado());
        break;
      case 'OPEN':
        _device.abrir();
        break;
      case 'CLOSE':
        _device.cerrar();
        break;
      default:
        _device.publicarMensaje('ERROR:UNKNOWN_COMMAND');
    }
  }
}

/// Enruta los comandos al canal adecuado sin cambiar la interfaz que utiliza
/// el controlador: Bluetooth para dispositivos físicos y memoria para demo.
class SimulatedAwareLockCommandChannel implements LockCommandChannel {
  SimulatedAwareLockCommandChannel({
    required LockCommandChannel bluetoothChannel,
    required LockCommandChannel simulatedChannel,
  })  : _bluetoothChannel = bluetoothChannel,
        _simulatedChannel = simulatedChannel;

  final LockCommandChannel _bluetoothChannel;
  final LockCommandChannel _simulatedChannel;

  @override
  Future<void> enviar(LockDevice device, String comando) {
    if (device is SimulatedLockDevice) {
      return _simulatedChannel.enviar(device, comando);
    }
    return _bluetoothChannel.enviar(device, comando);
  }
}
