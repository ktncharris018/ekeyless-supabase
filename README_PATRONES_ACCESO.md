# RF-21 — Gestión de perfiles de acceso inteligentes

Se agregó el módulo de perfiles de acceso reutilizables descrito en `cambios a aplicar.docx`.

## Flujo implementado

`PerfilAcceso → Prototype → Builder → Factory Method → Abstract Factory → AccessSessionManager → candado`

- **Prototype:** `PerfilAcceso.clone()` duplica una configuración sin reutilizar su identificador ni las listas mutables.
- **Builder:** `AutorizacionBuilder` construye y valida autorizaciones complejas.
- **Factory Method:** `AutorizacionCreator` tiene creadores concretos para permanente, temporal y recurrente.
- **Abstract Factory:** `LockCommunicationFactory` define las familias Bluetooth/NFC. Bluetooth reutiliza `BleLockGateway`; NFC queda modelado como extensión arquitectónica y no se presenta como implementación física.
- **Singleton:** `AccessSessionManager.instance` mantiene el único contexto activo de control de acceso.

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

## Supabase

Para una instalación nueva se puede ejecutar `supabase/schema.sql` completo.

Para un proyecto que ya ejecutó el esquema anterior, ejecutar solamente:

`supabase/migration_rf21_perfiles_acceso.sql`

La migración crea `perfiles_acceso`, `perfiles_acceso_historial` y el soporte de `invitadosRecurrentes` en `candados`, además de actualizar RLS.
