import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CompartirAccesoController extends GetxController {
  final CandadoBLEService _service = CandadoBLEService();

  // ==================== ESTADO ====================
  final cargando = false.obs;
  final cargandoAmigos = false.obs;
  final cargandoInvitados = false.obs;

  // ==================== DATOS ====================
  // *** CAMBIO: Hacer el candado observable ***
  final candadoObs = Rxn<CandadoModel>();
  CandadoModel get candado => candadoObs.value!;
  set candado(CandadoModel value) => candadoObs.value = value;
  //late final CandadoModel candado;
  final amigos = <UsuarioModel>[].obs;
  final invitadosPermanentes = <UsuarioModel>[].obs;
  final invitadosTemporales = <Map<String, dynamic>>[].obs;

  // ==================== FORMULARIO ====================
  final amigoSeleccionado = Rxn<UsuarioModel>();
  final esTemporal = false.obs;
  final fechaExpiracion = Rxn<DateTime>();
  final horaExpiracion = Rxn<TimeOfDay>();

  // ==================== COMPUTED ====================

  /// Obtiene la fecha y hora de expiración combinadas
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

  /// Verifica si la fecha de expiración es válida
  bool get esFechaExpiracionValida {
    final fechaHora = fechaHoraExpiracion;
    return fechaHora != null && fechaHora.isAfter(DateTime.now());
  }

  /// Formatea la fecha de expiración para mostrar
  String get fechaExpiracionFormateada {
    final fechaHora = fechaHoraExpiracion;
    if (fechaHora == null) return 'No seleccionada';

    return DateFormat('dd/MM/yyyy HH:mm').format(fechaHora);
  }

  /// Lista de amigos que no tienen acceso al candado
  List<UsuarioModel> get amigosDisponibles {
    final idsConAcceso = <String>{};

    // Agregar IDs con acceso permanente
    idsConAcceso.addAll(candado.invitadosPermanentes);

    // Agregar IDs con acceso temporal válido
    for (final invitado in candado.invitadosTemporales) {
      if (invitado.fechaExpiracion.isAfter(DateTime.now())) {
        idsConAcceso.add(invitado.usuarioId);
      }
    }

    // Agregar el dueño
    idsConAcceso.add(candado.dueno);

    return amigos.where((amigo) => !idsConAcceso.contains(amigo.id)).toList();
  }

  @override
  void onInit() {
    super.onInit();

    // Obtener el candado de los argumentos
    final argumentos = Get.arguments;
    if (argumentos is CandadoModel) {
      candadoObs.value = argumentos; // *** CAMBIO: Usar observable ***
      //candado = argumentos;
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

  /// Carga la lista de amigos del usuario actual
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

  /// Carga los invitados existentes del candado
  Future<void> cargarInvitadosExistentes() async {
    try {
      cargandoInvitados.value = true;

      // Limpiar listas
      invitadosPermanentes.clear();
      invitadosTemporales.clear();

      // Cargar invitados permanentes
      await _cargarInvitadosPermanentes();

      // Cargar invitados temporales
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

  /// Selecciona un amigo para compartir acceso
  void seleccionarAmigo(UsuarioModel? amigo) {
    amigoSeleccionado.value = amigo;
  }

  /// Cambia el tipo de acceso (temporal/permanente)
  void cambiarTipoAcceso(bool temporal) {
    esTemporal.value = temporal;

    // Limpiar fecha si no es temporal
    if (!temporal) {
      fechaExpiracion.value = null;
      horaExpiracion.value = null;
    }
  }

  /// Selecciona la fecha de expiración
  void seleccionarFechaExpiracion(DateTime? fecha) {
    fechaExpiracion.value = fecha;
  }

  /// Selecciona la hora de expiración
  void seleccionarHoraExpiracion(TimeOfDay? hora) {
    horaExpiracion.value = hora;
  }

  /// Limpia el formulario
  void limpiarFormulario() {
    amigoSeleccionado.value = null;
    esTemporal.value = false;
    fechaExpiracion.value = null;
    horaExpiracion.value = null;
  }

  // ==================== COMPARTIR ACCESO ====================

  /// Comparte el acceso con el amigo seleccionado
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

      // *** NUEVA LÍNEA: Actualizar el objeto candado local ***
      await actualizarCandadoLocal();

      _mostrarExito('Acceso compartido correctamente');

      // Limpiar formulario y recargar datos
      limpiarFormulario();
      await _inicializar();
    } catch (e) {
      _mostrarError('Error al compartir acceso: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  /// Actualiza el candado desde la base de datos y notifica a la vista
  Future<void> actualizarCandadoLocal() async {
    try {
      final candadoActualizado = await _service.obtenerCandadoPorKey(
        candado.key,
      );
      if (candadoActualizado != null) {
        candadoObs.value =
            candadoActualizado; // Esto triggerea la actualización de la vista
      }
    } catch (e) {
      //print('Error al actualizar candado local: $e');
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

  /// Revoca el acceso permanente de un usuario
  Future<void> revocarAccesoPermanente(UsuarioModel usuario) async {
    try {
      cargando.value = true;

      // Actualizar el modelo local
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

  /// Revoca el acceso temporal de un usuario
  Future<void> revocarAccesoTemporal(UsuarioModel usuario) async {
    try {
      cargando.value = true;

      // Actualizar el modelo local
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

  /// Extiende el acceso temporal de un usuario
  Future<void> extenderAccesoTemporal(
    UsuarioModel usuario,
    DateTime nuevaFechaExpiracion,
  ) async {
    try {
      cargando.value = true;

      if (!nuevaFechaExpiracion.isAfter(DateTime.now())) {
        throw Exception('La nueva fecha debe ser futura');
      }

      // Actualizar el modelo local
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

  /// Formatea una fecha para mostrar
  String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  /// Verifica si un acceso temporal está activo
  bool esAccesoTemporalActivo(DateTime fechaExpiracion) {
    return fechaExpiracion.isAfter(DateTime.now());
  }

  /// Obtiene el texto del estado de un acceso temporal
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
    } else {
      return 'Expirado';
    }
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

  @override
  void onClose() {
    // Limpiar recursos si es necesario
    super.onClose();
  }
}
