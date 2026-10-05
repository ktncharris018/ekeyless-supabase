# eKeyLess - versión SOLID basada en el diagrama

Esta versión conserva el proyecto eKeyLess original y aplica únicamente las separaciones de responsabilidades y abstracciones que aparecen en el diagrama SOLID entregado. Las vistas, rutas, modelos y flujo funcional se mantienen.

## Estructura del diagrama

### Autenticación
- `AuthService` coordina autenticación y depende de `UsuarioRepository` e `ImageStorageRepository`.
- `AuthStrategy` define la estrategia de autenticación; `EmailPasswordAuthStrategy` y `GoogleAuthStrategy` son implementaciones.
- `AuthExceptionMapper` separa el mapeo de errores de Supabase.
- `SupabaseStorageService` se conserva para el flujo de registro.

### Amigos y notificaciones
- `AmigosService` coordina `UsuarioRepository`, `AmistadRepository` y `NotificacionRepository`.
- `NotificacionService` usa `NotificacionRepository`.
- `SupabaseUsuarioRepository`, `SupabaseAmistadRepository` y `SupabaseNotificacionRepository` representan las implementaciones de acceso a datos del diagrama.

### Candados y Bluetooth
- `CandadoRepository` abstrae el acceso a candados y `SupabaseCandadoRepository` lo implementa.
- `BleLockGateway` abstrae las operaciones Bluetooth.
- `FlutterBluetoothService` es el adaptador concreto para `flutter_blue_plus`.
- `IPermissionService` e `ILocationService` separan permisos y GPS.
- `CandadoBLEService` coordina la lógica del candado y consume estas abstracciones.

## Principios SOLID

**SRP:** el mapeo de errores de autenticación está separado en `AuthExceptionMapper`, y los filtros repetidos de amigos se centralizaron. La lógica BLE, permisos y ubicación también están separadas mediante servicios especializados.

**OCP:** se pueden agregar estrategias, repositorios o adaptadores alternativos sin cambiar la lógica de los consumidores.

**LSP:** las implementaciones concretas sustituyen a sus abstracciones mediante `implements`.

**ISP:** los módulos trabajan con interfaces específicas (`UsuarioRepository`, `NotificacionRepository`, `CandadoRepository`, `AmistadRepository`, `BleLockGateway`, `IPermissionService`, `ILocationService`).

**DIP:** `AuthService`, `AmigosService`, `NotificacionService` y `CandadoBLEService` reciben dependencias abstractas por constructor. Además, los controladores de candados y notificaciones reciben explícitamente sus dependencias desde la composición de rutas.

## Cambios deliberadamente evitados

No se rediseñaron pantallas, rutas ni modelos. Solo se modificaron dependencias y responsabilidades necesarias para acercar el código al diagrama SOLID. La inyección de dependencias que se agregó para notificaciones y Bluetooth es explícita en los constructores y en los bindings de las rutas.

## Validación

Este entorno no tiene instalado el comando `flutter`, por lo que no fue posible ejecutar `flutter analyze` ni compilar la aplicación. Se realizó una revisión estática de imports, clases y referencias.
