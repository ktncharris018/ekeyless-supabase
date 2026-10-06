import 'dart:async';

import 'package:ekeyless/models/candado_model.dart';
import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:ekeyless/patterns/access/access_session_manager.dart';
import 'package:ekeyless/patterns/access/autorizacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class CandadoBLEController extends GetxController {
  CandadoBLEController({
    required CandadoBLEService service,
    required BleLockGateway bleGateway,
  })  : _service = service,
        _bleGateway = bleGateway;

  final CandadoBLEService _service;
  final BleLockGateway _bleGateway;

  // ==================== ESTADO GENERAL ====================
  final cargando = false.obs;
  final mensajeEstado = ''.obs;
  final conectado = false.obs;

  // ==================== ESTADO DE CANDADOS ====================
  final cargandoCandados = true.obs;
  final candadosUsuario = <CandadoModel>[].obs;
  final candadoActual = Rxn<CandadoModel>();

  // ==================== ESTADO BLUETOOTH ====================
  final dispositivosDisponibles = <BluetoothDevice>[].obs;
  final dispositivoSeleccionado = Rxn<BluetoothDevice>();
  final escaneoActivo = false.obs;
  final escaneoFinalizado = false.obs;
  
  StreamSubscription<List<BluetoothDevice>>? _escaneoSubscription;
  StreamSubscription<String>? _estadoSubscription;

  // ==================== UTILIDADES ====================
  User? get currentUser => _service.currentUser;

  @override
  void onInit() {
    super.onInit();
    _inicializar();
  }

  @override
  void onClose() {
    _limpiarRecursos();
    super.onClose();
  }

  // ==================== INICIALIZACIÓN ====================

  Future<void> _inicializar() async {
    await cargarCandadosUsuario();
  }

  void _limpiarRecursos() {
    _escaneoSubscription?.cancel();
    _estadoSubscription?.cancel();
    _service.dispose();
  }

  // ==================== GESTIÓN DE CANDADOS ====================

  /// Carga la lista de candados del usuario
  Future<void> cargarCandadosUsuario() async {
    try {
      cargandoCandados.value = true;
      final candados = await _service.obtenerCandadosUsuario();
      candadosUsuario.assignAll(candados);
    } catch (e) {
      _mostrarError('Error al cargar candados: ${e.toString()}');
      candadosUsuario.clear();
    } finally {
      cargandoCandados.value = false;
    }
  }

  /// Navega a la vista de vinculación
  void irAVincularCandado() {
    _reiniciarEstadoVinculacion();
    Get.toNamed(AppRoutes.vincularCandado);
  }

  /// Navega a la vista de control
  void irAControlCandado(CandadoModel candado) {
    final user = currentUser;
    if (user != null) {
      AccessSessionManager.instance.iniciar(
        usuarioId: user.id,
        candadoKey: candado.key,
        autorizacion: Autorizacion(
          usuarioId: user.id,
          candadoKey: candado.key,
          dispositivoId: null,
          tipoAcceso: TipoAccesoPerfil.permanente,
          fechaInicio: DateTime.now(),
          fechaFin: null,
          diasPermitidos: const [],
          horaInicioMinutos: null,
          horaFinMinutos: null,
          canalComunicacion: CanalComunicacion.bluetooth,
        ),
      );
    }
    candadoActual.value = candado;
    Get.toNamed(AppRoutes.control, arguments: candado);
  }

  /// Navega a la vista de compartir acceso
  void irACompartirAcceso(CandadoModel candado) {
    Get.toNamed(AppRoutes.compartirAcceso, arguments: candado);
  }

  /// Navega al módulo de perfiles de acceso reutilizables.
  void irAPerfilesAcceso(CandadoModel candado) {
    Get.toNamed(AppRoutes.perfilesAcceso, arguments: candado);
  }

  // ==================== VINCULACIÓN DE CANDADOS ====================

  void _reiniciarEstadoVinculacion() {
    dispositivoSeleccionado.value = null;
    dispositivosDisponibles.clear();
    escaneoFinalizado.value = false;
    escaneoActivo.value = false;
    mensajeEstado.value = '';
  }

  /// Inicia el proceso de vinculación
  Future<void> iniciarVinculacion() async {
    try {
      cargando.value = true;
      
      // Verificar soporte y permisos
      if (!await _bleGateway.esBluetoothSoportado()) {
        throw Exception('Bluetooth no es compatible con este dispositivo');
      }

      if (!await _bleGateway.solicitarPermisos()) {
        throw Exception('Permisos necesarios no concedidos');
      }

      if (!await _bleGateway.esBluetoothEncendido()) {
        await _bleGateway.encenderBluetooth();
      }

      if (!await _bleGateway.verificarGPS()) {
        throw Exception('GPS debe estar activado');
      }

      await _iniciarEscaneo();
      
    } catch (e) {
      _mostrarError(e.toString());
    } finally {
      cargando.value = false;
    }
  }

  /// Inicia el escaneo de dispositivos
  Future<void> _iniciarEscaneo() async {
    try {
      escaneoActivo.value = true;
      escaneoFinalizado.value = false;
      dispositivosDisponibles.clear();

      final candadosRegistrados = await _service.obtenerCandadosRegistrados();

      _escaneoSubscription?.cancel();
      _escaneoSubscription = _bleGateway.escanearDispositivos().listen(
        (dispositivos) {
          final dispositivosValidos = dispositivos.where((dispositivo) {
            final nombre = dispositivo.platformName.toLowerCase();
            return !candadosRegistrados.contains(nombre);
          }).toList();
          
          dispositivosDisponibles.assignAll(dispositivosValidos);
        },
        onDone: () {
          escaneoActivo.value = false;
          escaneoFinalizado.value = true;
        },
        onError: (error) {
          escaneoActivo.value = false;
          _mostrarError('Error durante el escaneo: $error');
        },
      );
    } catch (e) {
      escaneoActivo.value = false;
      _mostrarError('Error al iniciar escaneo: $e');
    }
  }

  /// Detiene el escaneo
  Future<void> detenerEscaneo() async {
    await _bleGateway.detenerEscaneo();
    _escaneoSubscription?.cancel();
    escaneoActivo.value = false;
  }

  /// Selecciona un dispositivo para vincular
  void seleccionarDispositivo(BluetoothDevice? dispositivo) {
    dispositivoSeleccionado.value = dispositivo;
  }

  /// Vincula el dispositivo seleccionado
  Future<void> vincularDispositivo() async {
    final dispositivo = dispositivoSeleccionado.value;
    if (dispositivo == null) {
      _mostrarError('Selecciona un candado para vincular');
      return;
    }

    try {
      cargando.value = true;
      mensajeEstado.value = 'Conectando...';

      await _bleGateway.conectarDispositivo(dispositivo);
      conectado.value = true;
      mensajeEstado.value = 'Conectado, obteniendo información...';

      await _procesarVinculacion(dispositivo);
      
    } catch (e) {
      conectado.value = false;
      _mostrarError('Error al vincular: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> _procesarVinculacion(BluetoothDevice dispositivo) async {
    try {
      // Suscribirse a notificaciones de estado
      _estadoSubscription?.cancel();
      _estadoSubscription = _bleGateway.suscribirEstado(dispositivo).listen(
        (mensaje) async {
          mensajeEstado.value = mensaje;
          await _procesarMensajeEstado(mensaje, dispositivo);
        },
        onError: (error) {
          _mostrarError('Error en comunicación: $error');
        },
      );

      // Solicitar key después de un breve delay
      await Future.delayed(const Duration(seconds: 2));
      await _bleGateway.enviarComando(dispositivo, 'GETKEY');
      
    } catch (e) {
      throw Exception('Error en procesamiento de vinculación: $e');
    }
  }

  Future<void> _procesarMensajeEstado(String mensaje, BluetoothDevice dispositivo) async {
    try {
      if (mensaje.startsWith('KEY:')) {
        final key = mensaje.substring(4);
        await _procesarKeyRecibida(key, dispositivo);
      } else if (mensaje == 'OPENED' || mensaje == 'CLOSED' || mensaje.startsWith('STATUS:')) {
        // Actualizar estado visual
        mensajeEstado.value = mensaje;
      }
    } catch (e) {
      _mostrarError('Error procesando mensaje: $e');
    }
  }

  Future<void> _procesarKeyRecibida(String key, BluetoothDevice dispositivo) async {
    try {
      final user = _service.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final candadoExistente = await _service.obtenerCandadoPorKey(key);
      
      if (candadoExistente == null) {
        // Crear nuevo candado
        final nuevoCandado = CandadoModel(
          key: key,
          nombre: dispositivo.platformName,
          dueno: user.id,
          fechaCreacion: DateTime.now(),
        );
        
        await _service.guardarCandado(nuevoCandado);
        candadoActual.value = nuevoCandado;
        AccessSessionManager.instance.iniciar(
          usuarioId: user.id,
          candadoKey: nuevoCandado.key,
          autorizacion: Autorizacion(
            usuarioId: user.id,
            candadoKey: nuevoCandado.key,
            dispositivoId: dispositivo.remoteId.toString(),
            tipoAcceso: TipoAccesoPerfil.permanente,
            fechaInicio: DateTime.now(),
            fechaFin: null,
            diasPermitidos: const [],
            horaInicioMinutos: null,
            horaFinMinutos: null,
            canalComunicacion: CanalComunicacion.bluetooth,
          ),
        );
        Get.offNamed(AppRoutes.control, arguments: nuevoCandado);
      } else {
        // Verificar acceso a candado existente
        await _verificarAccesoCandado(candadoExistente, user.id);
      }
    } catch (e) {
      throw Exception('Error procesando key: $e');
    }
  }

  Future<void> _verificarAccesoCandado(CandadoModel candado, String usuarioId) async {
    final tipoAcceso = candado.obtenerRolUsuario(usuarioId);
    
    switch (tipoAcceso) {
      case TipoUsuario.dueno:
      case TipoUsuario.invitado:
        candadoActual.value = candado;
        Get.offNamed(AppRoutes.control, arguments: candado);
        break;
        
      case TipoUsuario.invitadoTemporal:
        if (_service.validarAccesoTemporal(candado, usuarioId)) {
          candadoActual.value = candado;
          Get.offNamed(AppRoutes.control, arguments: candado);
        } else {
          throw Exception('Acceso temporal expirado');
        }
        break;

      case TipoUsuario.invitadoRecurrente:
        candadoActual.value = candado;
        Get.offNamed(AppRoutes.control, arguments: candado);
        break;
        
      default:
        throw Exception('No tienes acceso a este candado');
    }
  }

  // ==================== CONTROL DE CANDADOS ====================

  /// Reconecta a un candado existente
  Future<void> reconectarCandado(CandadoModel candado) async {
    try {
      cargando.value = true;
      mensajeEstado.value = 'Buscando candado...';
      
      if (!await _bleGateway.solicitarPermisos()) {
        throw Exception('Permisos necesarios no concedidos');
      }

      if (!await _bleGateway.esBluetoothEncendido()) {
        await _bleGateway.encenderBluetooth();
      }

      await _buscarYConectarCandado(candado);
      
    } catch (e) {
      _mostrarError('Error al reconectar: ${e.toString()}');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> _buscarYConectarCandado(CandadoModel candado) async {
    final nombreCandado = candado.nombre.toLowerCase();
    
    await for (final dispositivos in _bleGateway.escanearDispositivos()) {
      for (final dispositivo in dispositivos) {
        if (dispositivo.platformName.toLowerCase() == nombreCandado) {
          await _bleGateway.detenerEscaneo();
          dispositivoSeleccionado.value = dispositivo;
          await _conectarParaControl(dispositivo);
          return;
        }
      }
    }
    
    throw Exception('Candado no encontrado');
  }

  Future<void> _conectarParaControl(BluetoothDevice dispositivo) async {
    try {
      await _bleGateway.conectarDispositivo(dispositivo);
      conectado.value = true;
      AccessSessionManager.instance.actualizarConexion(true);
      mensajeEstado.value = 'Conectado';

      // Suscribirse a estado
      _estadoSubscription?.cancel();
      _estadoSubscription = _bleGateway.suscribirEstado(dispositivo).listen(
        (mensaje) {
          mensajeEstado.value = mensaje;
        },
        onError: (error) {
          _mostrarError('Error en comunicación: $error');
        },
      );

      // Solicitar estado inicial
      await Future.delayed(const Duration(seconds: 1));
      await _bleGateway.enviarComando(dispositivo, 'STATUS');
      
    } catch (e) {
      throw Exception('Error al conectar para control: $e');
    }
  }

  /// Desconecta el candado actual
  Future<void> desconectarCandado() async {
    try {
      final dispositivo = dispositivoSeleccionado.value;
      if (dispositivo != null) {
        await _bleGateway.desconectarDispositivo(dispositivo);
      }
      
      _estadoSubscription?.cancel();
      dispositivoSeleccionado.value = null;
      conectado.value = false;
      AccessSessionManager.instance.actualizarConexion(false);
      mensajeEstado.value = 'Desconectado';
      
    } catch (e) {
      _mostrarError('Error al desconectar: ${e.toString()}');
    }
  }

  /// Envía comando al candado
  Future<void> enviarComando(String comando) async {
    final dispositivo = dispositivoSeleccionado.value;
    if (dispositivo == null || !conectado.value) {
      _mostrarError('Candado no conectado');
      return;
    }

    try {
      await _bleGateway.enviarComando(dispositivo, comando);
    } catch (e) {
      _mostrarError('Error al enviar comando: ${e.toString()}');
    }
  }

  /// Regresa al listado de candados
  Future<void> volverAlListado() async {
    await desconectarCandado();
    await cargarCandadosUsuario();
    Get.offAllNamed(AppRoutes.candado);
  }

  // ==================== UTILIDADES ====================

  bool get esCandadoAbierto {
    final estado = mensajeEstado.value;
    return estado.contains('OPENED') || estado.contains('STATUS:OPEN');
  }

  void _mostrarError(String mensaje) {
    Get.snackbar(
      'Error',
      mensaje,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}