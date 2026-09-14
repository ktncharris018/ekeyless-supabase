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
- `IBleLockGateway` abstrae las operaciones Bluetooth.
- `FlutterBluetoothService` es el adaptador concreto para `flutter_blue_plus`.
- `IPermissionService` e `ILocationService` separan permisos y GPS.
- `CandadoBLEService` coordina la lógica del candado y consume estas abstracciones.

## Principios SOLID

**SRP:** autenticación, mapeo de errores, persistencia, Bluetooth, permisos y ubicación están separados.

**OCP:** se pueden agregar estrategias, repositorios o adaptadores alternativos sin cambiar la lógica de los consumidores.

**LSP:** las implementaciones concretas sustituyen a sus abstracciones mediante `implements`.

**ISP:** los módulos trabajan con interfaces específicas (`UsuarioRepository`, `NotificacionRepository`, `CandadoRepository`, `IBleLockGateway`, `IPermissionService`, `ILocationService`).

**DIP:** `AuthService` y `CandadoBLEService` reciben dependencias por constructor, de modo que la lógica principal no queda amarrada a una única implementación.

## Cambios deliberadamente evitados

No se rediseñaron pantallas, rutas ni modelos. Solo se modificaron dependencias y responsabilidades necesarias para acercar el código al diagrama SOLID. También se conservaron los pequeños ajustes funcionales que ya tenía el proyecto, como la inyección opcional de servicios en controladores.

## Validación

Este entorno no tiene instalado el comando `flutter`, por lo que no fue posible ejecutar `flutter analyze` ni compilar la aplicación. Se realizó una revisión estática de imports, clases y referencias.
