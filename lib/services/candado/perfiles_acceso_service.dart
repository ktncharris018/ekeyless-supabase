import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/invitado_recurrente_model.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/patterns/access/access_session_manager.dart';
import 'package:ekeyless/patterns/access/autorizacion.dart';
import 'package:ekeyless/patterns/access/autorizacion_creator.dart';
import 'package:ekeyless/patterns/access/prototype.dart';
import 'package:ekeyless/patterns/access/communication_factory.dart';
import 'package:ekeyless/repositories/perfil_acceso_repository.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilesAccesoService {
  PerfilesAccesoService({
    required SupabaseClient client,
    required PerfilAccesoRepository perfilRepository,
    required CandadoBLEService candadoService,
    required BleLockGateway bleGateway,
    AccessSessionManager? sessionManager,
  })  : _client = client,
        _perfilRepository = perfilRepository,
        _bleGateway = bleGateway,
        _candadoService = candadoService,
        _sessionManager = sessionManager ?? AccessSessionManager.instance;

  final SupabaseClient _client;
  final PerfilAccesoRepository _perfilRepository;
  final BleLockGateway _bleGateway;
  final CandadoBLEService _candadoService;
  final AccessSessionManager _sessionManager;

  User? get currentUser => _client.auth.currentUser;

  Future<List<PerfilAcceso>> obtenerPerfiles(String candadoKey) {
    _requireUser();
    return _perfilRepository.obtenerPorCandado(candadoKey);
  }

  Future<PerfilAcceso> guardarPerfil(PerfilAcceso perfil) async {
    _requireOwner(perfil.propietarioId);
    await _validarCandadoPropietario(perfil.candadoKey, perfil.propietarioId);
    final guardado = await _perfilRepository.guardar(perfil);
    await _registrar(guardado, 'crear', {'nombre': guardado.nombre});
    return guardado;
  }

  Future<void> actualizarPerfil(PerfilAcceso perfil) async {
    _requireOwner(perfil.propietarioId);
    await _validarCandadoPropietario(perfil.candadoKey, perfil.propietarioId);
    final actualizado = perfil.copyWith(fechaActualizacion: DateTime.now());
    await _perfilRepository.actualizar(actualizado);
    await _registrar(actualizado, 'modificar', {'nombre': actualizado.nombre});
  }

  Future<PerfilAcceso> duplicarPerfil(PerfilAcceso perfil) async {
    _requireOwner(perfil.propietarioId);
    final prototypeStore = PrototypeStore<PerfilAcceso>()..registrar(perfil);
    final clonado = prototypeStore.getObject(perfil.prototypeKey).copyWith(
      nombre: '${perfil.nombre} (copia)',
    );
    final guardado = await _perfilRepository.guardar(clonado);
    await _registrar(guardado, 'duplicar', {'origen': perfil.id});
    return guardado;
  }

  Future<void> eliminarPerfil(PerfilAcceso perfil) async {
    _requireOwner(perfil.propietarioId);
    if (perfil.id == null) return;
    await _registrar(perfil, 'eliminar', {'nombre': perfil.nombre});
    await _perfilRepository.eliminar(perfil.id!);
  }

  Future<Autorizacion> construirAutorizacion(PerfilAcceso perfil) async {
    _requireOwner(perfil.propietarioId);
    final AutorizacionCreator creator;
    switch (perfil.tipoAcceso) {
      case TipoAccesoPerfil.permanente:
        creator = AutorizacionPermanenteCreator();
        break;
      case TipoAccesoPerfil.temporal:
        creator = AutorizacionTemporalCreator();
        break;
      case TipoAccesoPerfil.recurrente:
        creator = AutorizacionRecurrenteCreator();
        break;
    }
    return creator.crear(perfil);
  }

  Future<void> asignarPerfil(PerfilAcceso perfil) async {
    final autorizacion = await construirAutorizacion(perfil);
    final communicationFactory = LockCommunicationFactoryProvider.forChannel(
      perfil.canalComunicacion,
      bluetoothGateway: _bleGateway,
    );

    if (!communicationFactory.implementada) {
      throw UnsupportedError(
        'El canal ${perfil.canalComunicacion.label} está modelado como extensión arquitectónica y aún no está implementado.',
      );
    }

    // Fuerza la creación de la familia completa de productos de comunicación.
    communicationFactory.createScanner();
    communicationFactory.createConnector();
    communicationFactory.createCommandChannel();

    final candado = await _candadoService.obtenerCandadoPorKey(perfil.candadoKey);
    if (candado == null) {
      throw Exception('El candado ya no existe');
    }
    if (candado.dueno != perfil.propietarioId) {
      throw Exception('Solo el propietario puede asignar este perfil');
    }

    final actualizado = _aplicarAutorizacion(candado, autorizacion);
    await _candadoService.actualizarCandado(actualizado);

    _sessionManager.iniciar(
      usuarioId: autorizacion.usuarioId,
      candadoKey: autorizacion.candadoKey,
      autorizacion: autorizacion,
    );

    await _registrar(
      perfil,
      'asignar',
      {
        'usuarioId': autorizacion.usuarioId,
        'tipoAcceso': autorizacion.tipoAcceso.value,
        'canal': autorizacion.canalComunicacion.value,
      },
    );
  }

  Future<void> revocarPerfil(PerfilAcceso perfil) async {
    final candado = await _candadoService.obtenerCandadoPorKey(perfil.candadoKey);
    if (candado == null) throw Exception('El candado ya no existe');
    if (candado.dueno != perfil.propietarioId) {
      throw Exception('Solo el propietario puede revocar este perfil');
    }

    CandadoModel actualizado;
    switch (perfil.tipoAcceso) {
      case TipoAccesoPerfil.permanente:
        actualizado = candado.copyWith(
          invitadosPermanentes:
              List<String>.from(candado.invitadosPermanentes)..remove(perfil.usuarioId),
        );
        break;
      case TipoAccesoPerfil.temporal:
        actualizado = candado.copyWith(
          invitadosTemporales: candado.invitadosTemporales
              .where((item) => item.usuarioId != perfil.usuarioId)
              .toList(),
        );
        break;
      case TipoAccesoPerfil.recurrente:
        actualizado = candado.copyWith(
          invitadosRecurrentes: candado.invitadosRecurrentes
              .where((item) => item.usuarioId != perfil.usuarioId)
              .toList(),
        );
        break;
    }

    await _candadoService.actualizarCandado(actualizado);
    await _registrar(perfil, 'revocar', {'usuarioId': perfil.usuarioId});
  }

  CandadoModel _aplicarAutorizacion(
    CandadoModel candado,
    Autorizacion autorizacion,
  ) {
    switch (autorizacion.tipoAcceso) {
      case TipoAccesoPerfil.permanente:
        final invitados = List<String>.from(candado.invitadosPermanentes);
        if (!invitados.contains(autorizacion.usuarioId)) {
          invitados.add(autorizacion.usuarioId);
        }
        return candado.copyWith(invitadosPermanentes: invitados);

      case TipoAccesoPerfil.temporal:
        if (autorizacion.fechaFin == null) {
          throw ArgumentError('Una autorización temporal requiere fecha final');
        }
        final invitados = candado.invitadosTemporales
            .where((item) => item.usuarioId != autorizacion.usuarioId)
            .toList();
        invitados.add(
          InvitadoTemporal(
            usuarioId: autorizacion.usuarioId,
            fechaInicio: autorizacion.fechaInicio,
            fechaExpiracion: autorizacion.fechaFin!,
          ),
        );
        return candado.copyWith(invitadosTemporales: invitados);

      case TipoAccesoPerfil.recurrente:
        final inicio = autorizacion.fechaInicio;
        final offset = DateTime.now().timeZoneOffset.inMinutes;
        final invitados = candado.invitadosRecurrentes
            .where((item) => item.usuarioId != autorizacion.usuarioId)
            .toList();

        invitados.add(
          InvitadoRecurrente(
            usuarioId: autorizacion.usuarioId,
            fechaInicio: inicio,
            fechaFin: autorizacion.fechaFin,
            diasPermitidos: autorizacion.diasPermitidos,
            horaInicioMinutos: autorizacion.horaInicioMinutos!,
            horaFinMinutos: autorizacion.horaFinMinutos!,
            canalComunicacion: autorizacion.canalComunicacion.value,
            dispositivoId: autorizacion.dispositivoId,
            zonaHorariaOffsetMinutos: offset,
          ),
        );
        return candado.copyWith(invitadosRecurrentes: invitados);
    }
  }

  Future<void> _validarCandadoPropietario(
    String candadoKey,
    String propietarioId,
  ) async {
    final candado = await _candadoService.obtenerCandadoPorKey(candadoKey);
    if (candado == null) throw Exception('El candado no existe');
    if (candado.dueno != propietarioId) {
      throw Exception('El perfil debe pertenecer a un candado del propietario');
    }
  }

  void _requireUser() {
    if (currentUser == null) throw Exception('Usuario no autenticado');
  }

  void _requireOwner(String ownerId) {
    _requireUser();
    if (currentUser!.id != ownerId) {
      throw Exception('Solo el propietario puede gestionar perfiles de acceso');
    }
  }

  Future<void> _registrar(
    PerfilAcceso perfil,
    String operacion,
    Map<String, dynamic> detalles,
  ) async {
    try {
      await _perfilRepository.registrarHistorial(
        PerfilAccesoHistorial(
          perfilId: perfil.id,
          propietarioId: perfil.propietarioId,
          operacion: operacion,
          detalles: detalles,
        ),
      );
    } catch (_) {
      // La trazabilidad no debe interrumpir una operación ya completada.
    }
  }
}
