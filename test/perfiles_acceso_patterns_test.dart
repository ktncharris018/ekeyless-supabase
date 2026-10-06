import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/patterns/access/access_session_manager.dart';
import 'package:ekeyless/patterns/access/autorizacion_builder.dart';
import 'package:ekeyless/patterns/access/autorizacion_creator.dart';
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
      fechaFin: tipo == TipoAccesoPerfil.temporal ? DateTime(2026, 10, 10, 18) : null,
      diasPermitidos:
          tipo == TipoAccesoPerfil.recurrente ? [2, 4] : const [],
      horaInicioMinutos:
          tipo == TipoAccesoPerfil.recurrente ? 8 * 60 : null,
      horaFinMinutos:
          tipo == TipoAccesoPerfil.recurrente ? 12 * 60 : null,
    );
  }

  group('Prototype', () {
    test('clona el perfil sin reutilizar la misma lista de días ni el id', () {
      final original = perfilBase(TipoAccesoPerfil.recurrente);
      final copia = original.clone();

      expect(copia.id, isNull);
      expect(copia.nombre, original.nombre);
      expect(copia.candadoKey, original.candadoKey);
      expect(copia.diasPermitidos, orderedEquals(original.diasPermitidos));
      expect(identical(copia.diasPermitidos, original.diasPermitidos), isFalse);
    });
  });

  group('Builder y Factory Method', () {
    test('construye autorización temporal válida', () {
      final perfil = perfilBase(TipoAccesoPerfil.temporal);
      final autorizacion = AutorizacionCreatorFactory.para(perfil.tipoAcceso).crear(perfil);

      expect(autorizacion.tipoAcceso, TipoAccesoPerfil.temporal);
      expect(autorizacion.fechaFin, isNotNull);
      expect(autorizacion.usuarioId, 'user-1');
    });

    test('rechaza temporal sin fecha final', () {
      expect(
        () => AutorizacionBuilder()
            .paraUsuario('user-1')
            .paraCandado('lock-1')
            .tipo(TipoAccesoPerfil.temporal)
            .desde(inicio)
            .build(),
        throwsArgumentError,
      );
    });

    test('rechaza horario inválido', () {
      expect(
        () => AutorizacionBuilder()
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

  group('Singleton', () {
    test('AccessSessionManager mantiene una única instancia', () {
      final first = AccessSessionManager.instance;
      final second = AccessSessionManager.instance;
      expect(identical(first, second), isTrue);
      first.cerrar();
    });
  });
}
