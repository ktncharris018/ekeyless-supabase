# eKeyLess — migración Firebase → Supabase

Esta versión conserva la UI, rutas y flujo del candado BLE. Firebase/Firestore/Google Sign-In de Firebase fueron sustituidos por Supabase Auth, PostgreSQL, Realtime y Storage.

## 1. Configurar Supabase

1. Crea un proyecto en Supabase.
2. Abre **SQL Editor** y ejecuta `supabase/schema.sql`.
3. En Authentication > Providers habilita **Google** y configura el OAuth Client de Google.
4. Para conservar el comportamiento del registro original (entrar inmediatamente después de registrarse), desactiva **Confirm email**. Supabase devuelve usuario sin sesión cuando la confirmación está activa.
5. Crea un bucket de Storage llamado `avatars` y hazlo público para que las URLs de perfil funcionen como antes.
6. En Authentication > URL Configuration agrega `ekeyless://auth-callback` como Redirect URL.

## 2. Ejecutar Flutter

No se guardan credenciales de Supabase en el código. Ejecuta, por ejemplo:

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

También puedes colocar esos dos valores en tu configuración de ejecución de VS Code.

## 3. Google en Android/iOS

La aplicación usa el OAuth de Supabase con el esquema `ekeyless://auth-callback`. El AndroidManifest e Info.plist ya incluyen el deep link básico. Debes registrar en Supabase y en Google Cloud las URLs que correspondan a tu proyecto.

## 4. Patrones de diseño aplicados

- **Repository:** interfaces y adaptadores para usuarios, candados, notificaciones y almacenamiento.
- **Strategy:** autenticación por email/contraseña y Google.
- **Adapter:** `SupabaseImageStorageAdapter` reemplaza el backend de imágenes sin cambiar el controller de registro.
- **Factory:** se conservan `fromJson`, `crear` y otros factories existentes de los modelos.
- **Observer:** GetX (`Rx`, `Obx`) y Supabase Realtime para notificaciones.
- **Dependency Injection:** los repositorios aceptan `SupabaseClient` y se pueden inyectar sin acoplar el controller a una implementación concreta.
- **Singleton:** se conserva el Singleton de `CandadoBLEService` porque administra una única sesión BLE, minimizando cambios sobre el comportamiento del candado.

## 5. Candado BLE

No se cambió el protocolo BLE del proyecto: UUIDs, comandos (`OPEN`, `CLOSE`, `TOGGLE`, `STATUS`, `GETKEY`), descubrimiento de servicios, notificaciones, permisos, escaneo y conexión permanecen en `CandadoBLEService`. Solamente se reemplazó la persistencia/autenticación que antes estaba acoplada a Firebase.

## 6. Seguridad

No uses una `service_role` key en Flutter. La aplicación utiliza la publishable key y las tablas tienen RLS. Las operaciones de amistad que antes dependían de transacciones de Firestore ahora se ejecutan como RPC atómicas en PostgreSQL.
