import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/services/candado/perfiles_acceso_service.dart';
import 'package:ekeyless/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerfilesAccesoController extends GetxController {
  PerfilesAccesoController({required PerfilesAccesoService service})
      : _service = service;

  final PerfilesAccesoService _service;
  final cargando = false.obs;
  final perfiles = <PerfilAcceso>[].obs;
  late final CandadoModel candado;

  @override
  void onInit() {
    super.onInit();
    final argumentos = Get.arguments;
    if (argumentos is! CandadoModel) {
      Get.back();
      return;
    }
    candado = argumentos;
    cargarPerfiles();
  }

  Future<void> cargarPerfiles() async {
    try {
      cargando.value = true;
      perfiles.assignAll(await _service.obtenerPerfiles(candado.key));
    } catch (e) {
      _mostrarError('Error al cargar perfiles: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  void nuevoPerfil() {
    Get.toNamed(
      AppRoutes.editarPerfilAcceso,
      arguments: {'candado': candado},
    )?.then((_) => cargarPerfiles());
  }

  void editarPerfil(PerfilAcceso perfil) {
    Get.toNamed(
      AppRoutes.editarPerfilAcceso,
      arguments: {'candado': candado, 'perfil': perfil},
    )?.then((_) => cargarPerfiles());
  }

  Future<void> duplicarPerfil(PerfilAcceso perfil) async {
    try {
      cargando.value = true;
      await _service.duplicarPerfil(perfil);
      _mostrarExito('Perfil duplicado correctamente');
      await cargarPerfiles();
    } catch (e) {
      _mostrarError('Error al duplicar perfil: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> asignarPerfil(PerfilAcceso perfil) async {
    try {
      cargando.value = true;
      await _service.asignarPerfil(perfil);
      _mostrarExito('Perfil asignado y autorización generada');
      await cargarPerfiles();
    } catch (e) {
      _mostrarError('Error al asignar perfil: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> revocarPerfil(PerfilAcceso perfil) async {
    try {
      cargando.value = true;
      await _service.revocarPerfil(perfil);
      _mostrarExito('Autorización revocada correctamente');
    } catch (e) {
      _mostrarError('Error al revocar autorización: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> eliminarPerfil(PerfilAcceso perfil) async {
    try {
      cargando.value = true;
      await _service.eliminarPerfil(perfil);
      _mostrarExito('Perfil eliminado correctamente');
      await cargarPerfiles();
    } catch (e) {
      _mostrarError('Error al eliminar perfil: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> confirmarAccion({
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
    required Future<void> Function() accion,
  }) async {
    final confirmado = await Get.dialog<bool>(
      AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );

    if (confirmado == true) await accion();
  }

  String descripcionTipo(PerfilAcceso perfil) {
    return perfil.tipoAcceso.label;
  }

  String descripcionVigencia(PerfilAcceso perfil) {
    switch (perfil.tipoAcceso) {
      case TipoAccesoPerfil.permanente:
        return 'Sin fecha de finalización';
      case TipoAccesoPerfil.temporal:
        return 'Hasta ${perfil.fechaFin?.day.toString().padLeft(2, '0')}/${perfil.fechaFin?.month.toString().padLeft(2, '0')}/${perfil.fechaFin?.year}';
      case TipoAccesoPerfil.recurrente:
        return perfil.diasPermitidos.isEmpty
            ? 'Sin días definidos'
            : '${_dias(perfil.diasPermitidos)} · ${perfil.rangoHorario}';
    }
  }

  String _dias(List<int> dias) {
    const nombres = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias.map((day) => nombres[day - 1]).join(', ');
  }

  void _mostrarExito(String mensaje) {
    Get.snackbar(
      'Operación completada',
      mensaje,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
