import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:ekeyless/services/candado/perfiles_acceso_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditarPerfilAccesoController extends GetxController {
  EditarPerfilAccesoController({
    required PerfilesAccesoService service,
    required CandadoBLEService candadoService,
  })  : _service = service,
        _candadoService = candadoService;

  final PerfilesAccesoService _service;
  final CandadoBLEService _candadoService;

  final nombreController = TextEditingController();
  final dispositivoController = TextEditingController();
  final amigos = <UsuarioModel>[].obs;
  final cargando = false.obs;
  final cargandoAmigos = false.obs;

  late final CandadoModel candado;
  PerfilAcceso? perfilOriginal;

  final usuarioSeleccionado = Rxn<UsuarioModel>();
  final tipoAcceso = TipoAccesoPerfil.permanente.obs;
  final canalComunicacion = CanalComunicacion.bluetooth.obs;
  final fechaInicio = DateTime.now().obs;
  final fechaFin = Rxn<DateTime>();
  final horaInicioMinutos = Rxn<int>();
  final horaFinMinutos = Rxn<int>();
  final diasPermitidos = <int>{}.obs;

  bool get esEdicion => perfilOriginal != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final candadoArg = args?['candado'];
    if (candadoArg is! CandadoModel) {
      Get.back();
      return;
    }
    candado = candadoArg;
    perfilOriginal = args?['perfil'] is PerfilAcceso ? args!['perfil'] as PerfilAcceso : null;
    _inicializarPerfil();
    cargarAmigos();
  }

  void _inicializarPerfil() {
    final perfil = perfilOriginal;
    if (perfil == null) {
      nombreController.text = '';
      fechaInicio.value = DateTime.now();
      return;
    }

    nombreController.text = perfil.nombre;
    dispositivoController.text = perfil.dispositivoId ?? '';
    tipoAcceso.value = perfil.tipoAcceso;
    canalComunicacion.value = perfil.canalComunicacion;
    fechaInicio.value = perfil.fechaInicio;
    fechaFin.value = perfil.fechaFin;
    horaInicioMinutos.value = perfil.horaInicioMinutos;
    horaFinMinutos.value = perfil.horaFinMinutos;
    diasPermitidos.assignAll(perfil.diasPermitidos);
  }

  UsuarioModel? _buscarAmigo(String id) {
    for (final amigo in amigos) {
      if (amigo.id == id) return amigo;
    }
    return null;
  }

  Future<void> cargarAmigos() async {
    try {
      cargandoAmigos.value = true;
      amigos.assignAll(await _candadoService.obtenerAmigos());
      final usuarioId = perfilOriginal?.usuarioId;
      if (usuarioId != null) {
        usuarioSeleccionado.value = _buscarAmigo(usuarioId);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los usuarios: $e');
    } finally {
      cargandoAmigos.value = false;
    }
  }

  void cambiarTipo(TipoAccesoPerfil tipo) {
    tipoAcceso.value = tipo;
    if (tipo == TipoAccesoPerfil.permanente) {
      fechaFin.value = null;
      horaInicioMinutos.value = null;
      horaFinMinutos.value = null;
      diasPermitidos.clear();
    }
    if (tipo == TipoAccesoPerfil.temporal) {
      diasPermitidos.clear();
      horaInicioMinutos.value = null;
      horaFinMinutos.value = null;
    }
    if (tipo == TipoAccesoPerfil.recurrente && diasPermitidos.isEmpty) {
      diasPermitidos.add(DateTime.now().weekday);
      horaInicioMinutos.value ??= 8 * 60;
      horaFinMinutos.value ??= 17 * 60;
    }
  }

  void alternarDia(int dia) {
    if (diasPermitidos.contains(dia)) {
      diasPermitidos.remove(dia);
    } else {
      diasPermitidos.add(dia);
    }
    diasPermitidos.refresh();
  }

  void seleccionarFechaInicio(DateTime value) {
    fechaInicio.value = value;
  }

  void seleccionarFechaFin(DateTime value) {
    fechaFin.value = value;
  }

  void seleccionarHoraInicio(TimeOfDay value) {
    horaInicioMinutos.value = value.hour * 60 + value.minute;
  }

  void seleccionarHoraFin(TimeOfDay value) {
    horaFinMinutos.value = value.hour * 60 + value.minute;
  }

  TimeOfDay? get horaInicio {
    final value = horaInicioMinutos.value;
    if (value == null) return null;
    return TimeOfDay(hour: value ~/ 60, minute: value % 60);
  }

  TimeOfDay? get horaFin {
    final value = horaFinMinutos.value;
    if (value == null) return null;
    return TimeOfDay(hour: value ~/ 60, minute: value % 60);
  }

  Future<void> guardar() async {
    try {
      cargando.value = true;
      final usuario = usuarioSeleccionado.value;
      final nombre = nombreController.text.trim();
      final propietarioId = _service.currentUser?.id;

      if (propietarioId == null) throw Exception('Usuario no autenticado');
      if (nombre.isEmpty) throw Exception('El nombre del perfil es obligatorio');
      if (usuario == null) throw Exception('Selecciona un usuario autorizado');
      if (canalComunicacion.value == CanalComunicacion.nfc) {
        throw UnsupportedError(
          'NFC está definido como extensión arquitectónica, pero todavía no está implementado.',
        );
      }

      final perfil = PerfilAcceso.nuevo(
        propietarioId: propietarioId,
        nombre: nombre,
        candadoKey: candado.key,
        usuarioId: usuario.id,
        dispositivoId: dispositivoController.text,
        tipoAcceso: tipoAcceso.value,
        fechaInicio: fechaInicio.value,
        fechaFin: fechaFin.value,
        diasPermitidos: diasPermitidos.toList()..sort(),
        horaInicioMinutos: horaInicioMinutos.value,
        horaFinMinutos: horaFinMinutos.value,
        canalComunicacion: canalComunicacion.value,
      );

      if (perfilOriginal == null) {
        await _service.guardarPerfil(perfil);
      } else {
        final actualizado = perfil.copyWith(id: perfilOriginal!.id, fechaCreacion: perfilOriginal!.fechaCreacion);
        await _service.actualizarPerfil(actualizado);
      }

      Get.back(result: true);
      Get.snackbar(
        'Perfil guardado',
        'La configuración del perfil se guardó correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'No se pudo guardar',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      cargando.value = false;
    }
  }

  @override
  void onClose() {
    nombreController.dispose();
    dispositivoController.dispose();
    super.onClose();
  }
}
