import 'package:ekeyless/configs/auth_middleware.dart';
import 'package:ekeyless/controllers/amigos/amigos_controller.dart';
import 'package:ekeyless/controllers/auth/cambiarpassword_controller.dart';
import 'package:ekeyless/controllers/auth/login_controller.dart';
import 'package:ekeyless/controllers/auth/recuperarpassword_controller.dart';
import 'package:ekeyless/controllers/auth/registro_controller.dart';
import 'package:ekeyless/controllers/auth/splash_controller.dart';
import 'package:ekeyless/controllers/candado/candado_ble_controller.dart';
import 'package:ekeyless/controllers/candado/compartir_acceso_controller.dart';
import 'package:ekeyless/controllers/candado/perfiles_acceso_controller.dart';
import 'package:ekeyless/controllers/candado/editar_perfil_acceso_controller.dart';
import 'package:ekeyless/controllers/configuracion/configuracion_controller.dart';
import 'package:ekeyless/controllers/notificaciones/notificacion_controller.dart';
import 'package:ekeyless/services/candado/bluetooth_service.dart';
import 'package:ekeyless/services/candado/candadoble_service.dart';
import 'package:ekeyless/services/candado/perfiles_acceso_service.dart';
import 'package:ekeyless/services/notificaciones/notificacion_service.dart';
import 'package:ekeyless/views/amigos/vista_amigos.dart';
import 'package:ekeyless/views/auth/cambiar_password.dart';
import 'package:ekeyless/views/auth/login.dart';
import 'package:ekeyless/views/auth/recuperar_password.dart';
import 'package:ekeyless/views/auth/registro.dart';
import 'package:ekeyless/views/auth/splash_page.dart';
import 'package:ekeyless/views/candado/compartir_acceso.dart';
import 'package:ekeyless/views/candado/perfiles_acceso.dart';
import 'package:ekeyless/views/candado/editar_perfil_acceso.dart';
import 'package:ekeyless/views/candado/vincular_candado.dart';
import 'package:ekeyless/views/candado/vista_control.dart';
import 'package:ekeyless/views/candado/vista_lista_candado.dart';
import 'package:ekeyless/views/configuracion/vista_configuracion.dart';
import 'package:ekeyless/views/notificaciones/notificaciones_view.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ekeyless/repositories/perfil_acceso_repository.dart';

class AppRoutes {
  // ==================== RUTAS PÚBLICAS ====================

  static const String splash = '/splash';
  static const String login = '/login';
  static const String recuperarContrasena = '/recuperar-contrasena';
  static const String registro = '/registro';
  static const String cambiarContrasena = '/cambiar-contrasena';

  // ==================== RUTAS PRIVADAS ====================

  static const String candado = '/candado';
  static const String vincularCandado = '/vincular-candado';
  static const String control = '/control';
  static const String compartirAcceso = '/compartir-acceso';
  static const String perfilesAcceso = '/perfiles-acceso';
  static const String editarPerfilAcceso = '/editar-perfil-acceso';
  static const String amigos = '/amigos';
  static const String notificaciones = '/notificaciones';
  static const String configuracion = '/configuracion';

  static final routes = [
    // ==================== RUTAS PÚBLICAS ====================

    GetPage(
      name: splash,
      page: () => SplashPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController());
      }),
    ),

    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: BindingsBuilder(() {
        Get.delete<LoginController>();

        Get.lazyPut(() => LoginController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: recuperarContrasena,
      page: () => RecuperarPasswordPage(),
      binding: BindingsBuilder(() {
        Get.delete<RecuperarPasswordController>();

        Get.lazyPut(() => RecuperarPasswordController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: registro,
      page: () => RegistroPage(),
      binding: BindingsBuilder(() {
        Get.delete<RegistroController>();

        Get.lazyPut(() => RegistroController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: cambiarContrasena,
      page: () => CambiarPasswordPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CambiarPasswordController());
      }),
    ),

    // ==================== CANDADOS ====================
    GetPage(
      name: AppRoutes.candado,
      page: () => VistaListaCandados(),
      binding: BindingsBuilder(() {
        final bleGateway = FlutterBluetoothService();

        Get.put(
          CandadoBLEController(
            service: CandadoBLEService(bleGateway: bleGateway),
            bleGateway: bleGateway,
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.vincularCandado,
      page: () => VistaVincularCandado(),
      binding: BindingsBuilder(() {
        final bleGateway = FlutterBluetoothService();

        Get.put(
          CandadoBLEController(
            service: CandadoBLEService(bleGateway: bleGateway),
            bleGateway: bleGateway,
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.control,
      page: () => VistaControl(),
      binding: BindingsBuilder(() {
        final bleGateway = FlutterBluetoothService();

        Get.put(
          CandadoBLEController(
            service: CandadoBLEService(bleGateway: bleGateway),
            bleGateway: bleGateway,
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    // ==================== COMPARTIR ACCESO ====================
    GetPage(
      name: AppRoutes.compartirAcceso,
      page: () => VistaCompartirAcceso(),
      binding: BindingsBuilder(() {
        final bleGateway = FlutterBluetoothService();

        final service = CandadoBLEService(bleGateway: bleGateway);

        Get.put(
          CompartirAccesoController(service: service, bleGateway: bleGateway),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    // ==================== PERFILES DE ACCESO ====================
    GetPage(
      name: AppRoutes.perfilesAcceso,
      page: () => const VistaPerfilesAcceso(),
      binding: BindingsBuilder(() {
        final client = Supabase.instance.client;
        final bleGateway = FlutterBluetoothService();
        final candadoService = CandadoBLEService(
          client: client,
          bleGateway: bleGateway,
        );
        final perfilRepository = SupabasePerfilAccesoRepository(client: client);

        final service = PerfilesAccesoService(
          client: client,
          perfilRepository: perfilRepository,
          candadoService: candadoService,
          bleGateway: bleGateway,
        );

        Get.put(PerfilesAccesoController(service: service));
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.editarPerfilAcceso,
      page: () => const VistaEditarPerfilAcceso(),
      binding: BindingsBuilder(() {
        final client = Supabase.instance.client;
        final bleGateway = FlutterBluetoothService();
        final candadoService = CandadoBLEService(
          client: client,
          bleGateway: bleGateway,
        );
        final perfilRepository = SupabasePerfilAccesoRepository(client: client);

        final service = PerfilesAccesoService(
          client: client,
          perfilRepository: perfilRepository,
          candadoService: candadoService,
          bleGateway: bleGateway,
        );

        Get.put(
          EditarPerfilAccesoController(
            service: service,
            candadoService: candadoService,
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    // ==================== AMIGOS ====================
    GetPage(
      name: amigos,
      page: () => VistaAmigos(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AmigosController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    // ==================== NOTIFICACIONES ====================
    GetPage(
      name: notificaciones,
      page: () => NotificacionesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificacionService>(() => NotificacionService());

        Get.lazyPut(
          () =>
              NotificacionController(service: Get.find<NotificacionService>()),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),

    // ==================== CONFIGURACIÓN ====================
    GetPage(
      name: configuracion,
      page: () => VistaConfiguracion(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ConfiguracionController());
      }),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
