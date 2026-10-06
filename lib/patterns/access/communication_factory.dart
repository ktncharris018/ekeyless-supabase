import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class LockDevice {
  String get id;
  String get nombre;
}

class BluetoothLockDevice implements LockDevice {
  BluetoothLockDevice(this.device);

  final BluetoothDevice device;

  @override
  String get id => device.remoteId.toString();

  @override
  String get nombre => device.platformName.isEmpty ? id : device.platformName;
}

abstract class LockScanner {
  Future<List<LockDevice>> escanear({Duration timeout});
}

abstract class LockConnector {
  Future<void> conectar(LockDevice device);
}

abstract class LockCommandChannel {
  Future<void> enviar(LockDevice device, String comando);
}

abstract class LockCommunicationFactory {
  LockScanner createScanner();
  LockConnector createConnector();
  LockCommandChannel createCommandChannel();

  bool get implementada;
}

class BluetoothScanner implements LockScanner {
  BluetoothScanner(this._gateway);

  final BleLockGateway _gateway;

  @override
  Future<List<LockDevice>> escanear({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final result = await _gateway.escanearDispositivos(timeout: timeout).last;
    return result.map(BluetoothLockDevice.new).toList();
  }
}

class BluetoothConnector implements LockConnector {
  BluetoothConnector(this._gateway);

  final BleLockGateway _gateway;

  @override
  Future<void> conectar(LockDevice device) async {
    if (device is! BluetoothLockDevice) {
      throw ArgumentError('El dispositivo no pertenece a Bluetooth');
    }
    await _gateway.conectarDispositivo(device.device);
  }
}

class BluetoothCommandChannel implements LockCommandChannel {
  BluetoothCommandChannel(this._gateway);

  final BleLockGateway _gateway;

  @override
  Future<void> enviar(LockDevice device, String comando) async {
    if (device is! BluetoothLockDevice) {
      throw ArgumentError('El dispositivo no pertenece a Bluetooth');
    }
    await _gateway.enviarComando(device.device, comando);
  }
}

class BluetoothCommunicationFactory implements LockCommunicationFactory {
  BluetoothCommunicationFactory(this._gateway);

  final BleLockGateway _gateway;

  @override
  LockScanner createScanner() => BluetoothScanner(_gateway);

  @override
  LockConnector createConnector() => BluetoothConnector(_gateway);

  @override
  LockCommandChannel createCommandChannel() => BluetoothCommandChannel(_gateway);

  @override
  bool get implementada => true;
}

class NfcScanner implements LockScanner {
  @override
  Future<List<LockDevice>> escanear({Duration timeout = const Duration(seconds: 4)}) {
    throw UnsupportedError(
      'NFC está definido como extensión arquitectónica, pero todavía no tiene implementación física en eKeyLess.',
    );
  }
}

class NfcConnector implements LockConnector {
  @override
  Future<void> conectar(LockDevice device) {
    throw UnsupportedError(
      'NFC está definido como extensión arquitectónica, pero todavía no tiene implementación física en eKeyLess.',
    );
  }
}

class NfcCommandChannel implements LockCommandChannel {
  @override
  Future<void> enviar(LockDevice device, String comando) {
    throw UnsupportedError(
      'NFC está definido como extensión arquitectónica, pero todavía no tiene implementación física en eKeyLess.',
    );
  }
}

class NfcCommunicationFactory implements LockCommunicationFactory {
  @override
  LockScanner createScanner() => NfcScanner();

  @override
  LockConnector createConnector() => NfcConnector();

  @override
  LockCommandChannel createCommandChannel() => NfcCommandChannel();

  @override
  bool get implementada => false;
}

class LockCommunicationFactoryProvider {
  const LockCommunicationFactoryProvider._();

  static LockCommunicationFactory forChannel(
    CanalComunicacion channel, {
    required BleLockGateway bluetoothGateway,
  }) {
    switch (channel) {
      case CanalComunicacion.bluetooth:
        return BluetoothCommunicationFactory(bluetoothGateway);
      case CanalComunicacion.nfc:
        return NfcCommunicationFactory();
    }
  }
}
