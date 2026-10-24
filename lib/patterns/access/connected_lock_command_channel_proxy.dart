import 'communication_factory.dart';

/// Proxy que valida la conexión y la identidad del dispositivo activo antes
/// de permitir que un comando llegue al canal real o al simulador.
class ConnectedLockCommandChannelProxy implements LockCommandChannel {
  ConnectedLockCommandChannelProxy(
    this._delegate, {
    required bool Function() isConnected,
    required String? Function() selectedDeviceId,
  })  : _isConnected = isConnected,
        _selectedDeviceId = selectedDeviceId;

  final LockCommandChannel _delegate;
  final bool Function() _isConnected;
  final String? Function() _selectedDeviceId;

  @override
  Future<void> enviar(LockDevice device, String comando) async {
    if (!_isConnected()) {
      throw StateError(
        'No se puede enviar el comando: el candado no está conectado.',
      );
    }

    if (_selectedDeviceId() != device.id) {
      throw StateError(
        'No se puede enviar el comando: el dispositivo no es el candado activo.',
      );
    }

    await _delegate.enviar(device, comando);
  }
}
