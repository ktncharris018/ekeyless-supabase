# RF-21 — Gestión de perfiles de acceso inteligentes

Se agregó el módulo de perfiles de acceso reutilizables descrito en `cambios a aplicar.docx`.

## Flujo implementado

`PerfilAcceso → Prototype → Builder → Factory Method → Abstract Factory → Decorator → canal Bluetooth`

`AccessSessionManager` (Singleton) conserva el contexto activo de control de acceso.

- **Prototype:** `PrototypeStore` mantiene prototipos y `PerfilAcceso` es el prototipo concreto; `clone()` genera una copia sin reutilizar su identificador ni las listas mutables.
- **Builder:** `AutorizacionDirector` dirige la construcción mediante el contrato `AutorizacionBuilder` y sus builders concretos permanente, temporal y recurrente.
- **Factory Method:** `AutorizacionCreator` es el creador abstracto y sus creadores concretos devuelven `AutorizacionPermanente`, `AutorizacionTemporal` o `AutorizacionRecurrente`.
- **Abstract Factory:** `LockCommunicationFactory` define las familias Bluetooth/NFC. Bluetooth reutiliza `BleLockGateway`; NFC queda modelado como extensión arquitectónica y no se presenta como implementación física.
- **Singleton:** `AccessSessionManager.instance` mantiene el único contexto activo de control de acceso.
- **Decorator:** `LockCommandChannelDecorator` es el decorador base abstracto y conserva una referencia al `LockCommandChannel` que envuelve. `BluetoothCommandChannel` es el canal concreto y `LoggingLockCommandChannelDecorator` añade registro de diagnóstico sin cambiar ni validar el comando. Registra el inicio, la finalización o el error y la duración del intento de envío, sin modificar la implementación Bluetooth.


Diagrama UML actualizado del Decorator: `docs/diagrama_decorator_ekeyless_logging.png` (editable en SVG dentro de la misma carpeta).

## Funcionalidad de usuario

Desde **Mis Candados → menú del candado → Perfiles de acceso** se puede:

- crear un perfil;
- configurar usuario, dispositivo, tipo de acceso, vigencia, días, horario y canal;
- editarlo;
- duplicarlo sin alterar el original;
- asignarlo para generar una autorización;
- revocar la autorización generada;
- eliminar el perfil.

Los accesos recurrentes se guardan como parte del candado y se validan considerando fecha, día y horario.

Las órdenes de control pasan por `LoggingLockCommandChannelDecorator` antes de llegar al canal Bluetooth. El registro de finalización indica que el método de envío terminó sin error; no prueba que el candado físico haya ejecutado la orden. La autorización y validación de seguridad siguen correspondiendo al firmware y al protocolo del dispositivo.

## Supabase

Para una instalación nueva se puede ejecutar `supabase/schema.sql` completo.

Para un proyecto que ya ejecutó el esquema anterior, ejecutar solamente:

`supabase/migration_rf21_perfiles_acceso.sql`

La migración crea `perfiles_acceso`, `perfiles_acceso_historial` y el soporte de `invitadosRecurrentes` en `candados`, además de actualizar RLS.
