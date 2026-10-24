import 'dart:developer' as developer;

import 'communication_factory.dart';

/// Firma de la función que recibe los mensajes generados por el decorador.
/// Permite usar el registro normal de Dart o inyectar un registrador en pruebas.
typedef LockCommandLogCallback = void Function(
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// Decorador base abstracto que conserva el contrato del canal de comandos
/// y delega el envío al canal original. Las subclases pueden añadir tareas
/// sin modificar la implementación de Bluetooth.
abstract class LockCommandChannelDecorator implements LockCommandChannel {
  const LockCommandChannelDecorator(this._delegate);

  final LockCommandChannel _delegate;

  @override
  Future<void> enviar(LockDevice device, String comando) {
    return _delegate.enviar(device, comando);
  }
}

/// Registra el inicio, el resultado y la duración de cada intento de envío.
///
/// Este decorador no valida, modifica ni autoriza comandos: registra lo que
/// observa en el canal. Que [enviar] termine sin error solo indica que la
/// operación de envío del canal finalizó; no confirma que el candado físico
/// haya ejecutado la orden.
class LoggingLockCommandChannelDecorator
    extends LockCommandChannelDecorator {
  LoggingLockCommandChannelDecorator(
    LockCommandChannel delegate, {
    LockCommandLogCallback? logger,
  })  : _logger = logger ?? _defaultLogger,
        super(delegate);

  final LockCommandLogCallback _logger;

  static void _defaultLogger(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'eKeyLess.LockCommandChannel',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _registrar(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Un problema al escribir el registro no debe impedir que se envíe
    // el comando ni reemplazar la excepción real del canal.
    try {
      _logger(message, error: error, stackTrace: stackTrace);
    } on Object {
      // Se omite el error del registrador para preservar el flujo BLE.
    }
  }

  @override
  Future<void> enviar(LockDevice device, String comando) async {
    final cronometro = Stopwatch()..start();

    _registrar(
      'Inicio de envío del comando "$comando" al dispositivo ${device.id}.',
    );

    try {
      await super.enviar(device, comando);
      cronometro.stop();

      _registrar(
        'El canal terminó el envío del comando "$comando" al dispositivo '
        '${device.id} en ${cronometro.elapsedMilliseconds} ms. '
        'Esto no confirma la ejecución física de la orden.',
      );
    } catch (error, stackTrace) {
      cronometro.stop();

      _registrar(
        'Falló el envío del comando "$comando" al dispositivo ${device.id} '
        'después de ${cronometro.elapsedMilliseconds} ms.',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
