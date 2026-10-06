import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/patterns/access/access_session_manager.dart';
import 'package:ekeyless/patterns/access/autorizacion_builder.dart';
import 'package:ekeyless/patterns/access/autorizacion.dart';
import 'package:ekeyless/patterns/access/autorizacion_creator.dart';
import 'package:ekeyless/patterns/access/communication_factory.dart';
import 'package:ekeyless/patterns/access/prototype.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final inicio = DateTime(2026, 10, 6, 8, 0);

  PerfilAcceso perfilBase(TipoAccesoPerfil tipo) {
    return PerfilAcceso.nuevo(
      propietarioId: 'owner',
      nombre: 'Personal de limpieza',
      candadoKey: 'lock-1',
      usuarioId: 'user-1',
      tipoAcceso: tipo,
      fechaInicio: inicio,
      fechaFin: tipo == TipoAccesoPerfil.temporal
          ? DateTime(2026, 10, 10, 18)
          : null,
      diasPermitidos:
          tipo == TipoAccesoPerfil.recurrente ? [2, 4] : const [],
      horaInicioMinutos:
          tipo == TipoAccesoPerfil.recurrente ? 8 * 60 : null,
      horaFinMinutos:
          tipo == TipoAccesoPerfil.recurrente ? 12 * 60 : null,
    );
  }

  group('Prototype', () {
    test('PrototypeStore clona el perfil sin reutilizar la misma lista de días ni el id', () {
      final original = perfilBase(TipoAccesoPerfil.recurrente);
      final store = PrototypeStore<PerfilAcceso>()..registrar(original);
      final copia = store.getObject(original.prototypeKey);

      expect(copia.id, isNull);
      expect(copia.nombre, original.nombre);
      expect(copia.candadoKey, original.candadoKey);
      expect(copia.diasPermitidos, orderedEquals(original.diasPermitidos));
      expect(identical(copia.diasPermitidos, original.diasPermitidos), isFalse);
    });
  });

  group('Builder y Factory Method', () {
    test('Director y builder concreto construyen una autorización temporal válida', () {
      final perfil = perfilBase(TipoAccesoPerfil.temporal);
      final autorizacion = AutorizacionDirector(
        AutorizacionTemporalBuilder(),
      ).construirObjeto(perfil);

      expect(autorizacion, isA<AutorizacionTemporal>());
      expect(autorizacion.tipoAcceso, TipoAccesoPerfil.temporal);
      expect(autorizacion.fechaFin, isNotNull);
      expect(autorizacion.usuarioId, 'user-1');
    });

    test('Factory Method devuelve el producto concreto correspondiente', () {
      final perfil = perfilBase(TipoAccesoPerfil.recurrente);
      final autorizacion = AutorizacionRecurrenteCreator().crear(perfil);

      expect(autorizacion, isA<AutorizacionRecurrente>());
      expect(autorizacion.tipoAcceso, TipoAccesoPerfil.recurrente);
    });

    test('Builder rechaza temporal sin fecha final', () {
      expect(
        () => AutorizacionTemporalBuilder()
            .paraUsuario('user-1')
            .paraCandado('lock-1')
            .tipo(TipoAccesoPerfil.temporal)
            .desde(inicio)
            .build(),
        throwsArgumentError,
      );
    });

    test('Builder rechaza horario inválido', () {
      expect(
        () => AutorizacionRecurrenteBuilder()
            .paraUsuario('user-1')
            .paraCandado('lock-1')
            .tipo(TipoAccesoPerfil.recurrente)
            .desde(inicio)
            .enDias([2])
            .enHorario(18 * 60, 8 * 60)
            .build(),
        throwsArgumentError,
      );
    });
  });

  group('Abstract Factory', () {
    test('cada factory crea una familia completa de productos', () {
      final gateway = _FakeBleGateway();
      final factory = BluetoothCommunicationFactory(gateway);

      expect(factory.createScanner(), isA<BluetoothScanner>());
      expect(factory.createConnector(), isA<BluetoothConnector>());
      expect(factory.createCommandChannel(), isA<BluetoothCommandChannel>());
    });
  });

  group('Singleton', () {
    test('AccessSessionManager mantiene una única instancia', () {
      final first = AccessSessionManager.instance;
      final second = AccessSessionManager.instance;
      expect(identical(first, second), isTrue);
      first.cerrar();
    });
  });
}

class _FakeBleGateway implements BleLockGateway {
  @override
  Future<bool> esBluetoothSoportado() async => true;

  @override
  Future<bool> esBluetoothEncendido() async => true;

  @override
  Future<void> encenderBluetooth() async {}

  @override
  Future<bool> solicitarPermisos() async => true;

  @override
  Future<bool> verificarGPS() async => true;

  @override
  Stream<List<BluetoothDevice>> escanearDispositivos({
    Duration timeout = const Duration(seconds: 4),
    String filtroNombre = 'lock',
  }) async* {
    yield const [];
  }

  @override
  Future<void> detenerEscaneo() async {}

  @override
  Future<void> conectarDispositivo(BluetoothDevice dispositivo) async {}

  @override
  Future<void> desconectarDispositivo(BluetoothDevice dispositivo) async {}

  @override
  Future<void> enviarComando(BluetoothDevice dispositivo, String comando) async {}

  @override
  Stream<String> suscribirEstado(BluetoothDevice dispositivo) => const Stream.empty();

  @override
  void dispose() {}
}
