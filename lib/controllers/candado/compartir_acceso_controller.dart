import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CompartirAccesoController extends GetxController {
  CompartirAccesoController({
    required CandadoBLEService service,
    required BleLockGateway bleGateway,
  }) : _service = service,
       _bleGateway = bleGateway;

  final CandadoBLEService _service;
  final BleLockGateway _bleGateway;

  // Permite que el controlador dependa explícitamente
  // de la abstracción de comunicación Bluetooth.
  BleLockGateway get bleGateway => _bleGateway;

  // ==================== ESTADO ====================
  final cargando = false.obs;
  final cargandoAmigos = false.obs;
  final cargandoInvitados = false.obs;

  // ==================== DATOS ====================
  final candadoObs = Rxn<CandadoModel>();

  CandadoModel get candado => candadoObs.value!;
  set candado(CandadoModel value) => candadoObs.value = value;

  final amigos = <UsuarioModel>[].obs;
  final invitadosPermanentes = <UsuarioModel>[].obs;
  final invitadosTemporales = <Map<String, dynamic>>[].obs;

  // ==================== FORMULARIO ====================
  final amigoSeleccionado = Rxn<UsuarioModel>();
  final esTemporal = false.obs;
  final fechaExpiracion = Rxn<DateTime>();
  final horaExpiracion = Rxn<TimeOfDay>();

  // ==================== COMPUTED ====================

  DateTime? get fechaHoraExpiracion {
    final fecha = fechaExpiracion.value;
    final hora = horaExpiracion.value;

    if (fecha == null) return null;

    if (hora != null) {
      return DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    }

    return fecha;
  }

  bool get esFechaExpiracionValida {
    final fechaHora = fechaHoraExpiracion;
    return fechaHora != null && fechaHora.isAfter(DateTime.now());
  }

  String get fechaExpiracionFormateada {
    final fechaHora = fechaHoraExpiracion;

    if (fechaHora == null) {
      return 'No seleccionada';
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(fechaHora);
  }

  List<UsuarioModel> get amigosDisponibles {
    final idsConAcceso = <String>{};

    idsConAcceso.addAll(candado.invitadosPermanentes);

    for (final invitado in candado.invitadosTemporales) {
      if (invitado.fechaExpiracion.isAfter(DateTime.now())) {
        idsConAcceso.add(invitado.usuarioId);
      }
    }

    idsConAcceso.add(candado.dueno);

    return amigos.where((amigo) => !idsConAcceso.contains(amigo.id)).toList();
  }

  @override
  void onInit() {
    super.onInit();

    final argumentos = Get.arguments;

    if (argumentos is CandadoModel) {
      candadoObs.value = argumentos;
      _inicializar();
    } else {
      _mostrarError('Error al cargar información del candado');
      Get.back();
    }
  }

  // ==================== INICIALIZACIÓN ====================

  Future<void> _inicializar() async {
    await Future.wait([cargarAmigos(), cargarInvitadosExistentes()]);
  }

  // ==================== GESTIÓN DE AMIGOS ====================

  Future<void> cargarAmigos() async {
    try {
      cargandoAmigos.value = true;

      final listaAmigos = await _service.obtenerAmigos();
      amigos.assignAll(listaAmigos);
    } catch (e) {
      _mostrarError('Error al cargar amigos: ${e.toString()}');
      amigos.clear();
    } finally {
      cargandoAmigos.value = false;
    }
  }

  // ==================== GESTIÓN DE INVITADOS ====================

  Future<void> cargarInvitadosExistentes() async {
    try {
      cargandoInvitados.value = true;

      invitadosPermanentes.clear();
      invitadosTemporales.clear();

      await _cargarInvitadosPermanentes();
      await _cargarInvitadosTemporales();
    } catch (e) {
      _mostrarError('Error al cargar invitados: ${e.toString()}');
    } finally {
      cargandoInvitados.value = false;
    }
  }

  Future<void> _cargarInvitadosPermanentes() async {
    final List<UsuarioModel> permanentes = [];

    for (final usuarioId in candado.invitadosPermanentes) {
      final usuario = await _service.obtenerUsuarioPorId(usuarioId);

      if (usuario != null) {
        permanentes.add(usuario);
      }
    }

    invitadosPermanentes.assignAll(permanentes);
  }

  Future<void> _cargarInvitadosTemporales() async {
    final List<Map<String, dynamic>> temporales = [];

    for (final invitado in candado.invitadosTemporales) {
      final usuario = await _service.obtenerUsuarioPorId(invitado.usuarioId);

      if (usuario != null) {
        temporales.add({
          'usuario': usuario,
          'fechaExpiracion': invitado.fechaExpiracion,
          'activo': invitado.fechaExpiracion.isAfter(DateTime.now()),
        });
      }
    }

    invitadosTemporales.assignAll(temporales);
  }

  // ==================== FORMULARIO ====================

  void seleccionarAmigo(UsuarioModel? amigo) {
    amigoSeleccionado.value = amigo;
  }

  void cambiarTipoAcceso(bool temporal) {
    esTemporal.value = temporal;

    if (!temporal) {
      fechaExpiracion.value = null;
      horaExpiracion.value = null;
    }
  }

  void seleccionarFechaExpiracion(DateTime? fecha) {
    fechaExpiracion.value = fecha;
  }

  void seleccionarHoraExpiracion(TimeOfDay? hora) {
    horaExpiracion.value = hora;
  }

  void limpiarFormulario() {
    amigoSeleccionado.value = null;
    esTemporal.value = false;
    fechaExpiracion.value = null;
    horaExpiracion.value = null;
  }

  // ==================== COMPARTIR ACCESO ====================

  Future<void> compartirAcceso() async {
    if (!_validarFormulario()) return;

    try {
      cargando.value = true;

      await _service.compartirAcceso(
        candado: candado,
        usuarioId: amigoSeleccionado.value!.id,
        esTemporal: esTemporal.value,
        fechaExpiracion: esTemporal.value ? fechaHoraExpiracion : null,
      );

      await actualizarCandadoLocal();

      _mostrarExito('Acceso compartido correctamente');

      limpiarFormulario();
      await _inicializar();
    } catch (e) {
      _mostrarError('Error al compartir acceso: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> actualizarCandadoLocal() async {
    try {
      final candadoActualizado = await _service.obtenerCandadoPorKey(
        candado.key,
      );

      if (candadoActualizado != null) {
        candadoObs.value = candadoActualizado;
      }
    } catch (e) {
      // No se muestra error para no interrumpir el flujo principal.
    }
  }

  bool _validarFormulario() {
    if (amigoSeleccionado.value == null) {
      _mostrarError('Selecciona un amigo para compartir el acceso');
      return false;
    }

    if (esTemporal.value) {
      if (fechaExpiracion.value == null) {
        _mostrarError('Selecciona una fecha de expiración');
        return false;
      }

      if (!esFechaExpiracionValida) {
        _mostrarError('La fecha de expiración debe ser futura');
        return false;
      }
    }

    return true;
  }

  // ==================== GESTIÓN DE ACCESO EXISTENTE ====================

  Future<void> revocarAccesoPermanente(UsuarioModel usuario) async {
    try {
      cargando.value = true;

      final candadoActual = await _service.obtenerCandadoPorKey(candado.key);

      if (candadoActual == null) {
        throw Exception('El candado ya no existe');
      }

      final invitadosPermanentesActualizados = List<String>.from(
        candadoActual.invitadosPermanentes,
      );

      invitadosPermanentesActualizados.remove(usuario.id);

      final candadoActualizado = candadoActual.copyWith(
        invitadosPermanentes: invitadosPermanentesActualizados,
      );

      await _service.actualizarCandado(candadoActualizado);

      await actualizarCandadoLocal();

      _mostrarExito('Acceso revocado correctamente');

      await _inicializar();
    } catch (e) {
      _mostrarError('Error al revocar acceso: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> revocarAccesoTemporal(UsuarioModel usuario) async {
    try {
      cargando.value = true;

      final candadoActual = await _service.obtenerCandadoPorKey(candado.key);

      if (candadoActual == null) {
        throw Exception('El candado ya no existe');
      }

      final invitadosTemporalesActualizados =
          candadoActual.invitadosTemporales
              .where((invitado) => invitado.usuarioId != usuario.id)
              .toList();

      final candadoActualizado = candadoActual.copyWith(
        invitadosTemporales: invitadosTemporalesActualizados,
      );

      await _service.actualizarCandado(candadoActualizado);

      await actualizarCandadoLocal();

      _mostrarExito('Acceso temporal revocado correctamente');

      await _inicializar();
    } catch (e) {
      _mostrarError('Error al revocar acceso temporal: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> extenderAccesoTemporal(
    UsuarioModel usuario,
    DateTime nuevaFechaExpiracion,
  ) async {
    try {
      cargando.value = true;

      if (!nuevaFechaExpiracion.isAfter(DateTime.now())) {
        throw Exception('La nueva fecha debe ser futura');
      }

      final candadoActual = await _service.obtenerCandadoPorKey(candado.key);

      if (candadoActual == null) {
        throw Exception('El candado ya no existe');
      }

      final invitadosTemporalesActualizados =
          candadoActual.invitadosTemporales.map((invitado) {
            if (invitado.usuarioId == usuario.id) {
              return InvitadoTemporal(
                usuarioId: invitado.usuarioId,
                fechaExpiracion: nuevaFechaExpiracion,
              );
            }

            return invitado;
          }).toList();

      final candadoActualizado = candadoActual.copyWith(
        invitadosTemporales: invitadosTemporalesActualizados,
      );

      await _service.actualizarCandado(candadoActualizado);

      await actualizarCandadoLocal();

      _mostrarExito('Acceso temporal extendido correctamente');

      await _inicializar();
    } catch (e) {
      _mostrarError('Error al extender acceso: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  // ==================== UTILIDADES ====================

  String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  bool esAccesoTemporalActivo(DateTime fechaExpiracion) {
    return fechaExpiracion.isAfter(DateTime.now());
  }

  String obtenerEstadoAccesoTemporal(DateTime fechaExpiracion) {
    if (esAccesoTemporalActivo(fechaExpiracion)) {
      final diferencia = fechaExpiracion.difference(DateTime.now());

      if (diferencia.inDays > 0) {
        return 'Expira en ${diferencia.inDays} días';
      } else if (diferencia.inHours > 0) {
        return 'Expira en ${diferencia.inHours} horas';
      } else {
        return 'Expira en ${diferencia.inMinutes} minutos';
      }
    }

    return 'Expirado';
  }

  void _mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void _mostrarExito(String mensaje) {
    Get.snackbar(
      'Éxito',
      mensaje,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
}
