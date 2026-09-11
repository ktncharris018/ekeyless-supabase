import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dlmftcixrvfrwvynoykj.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_0fMo5jCoyK8OG7_aEa_QsA__7IUfO9x',
  );

  /// Redirect utilizado en Android/iOS.
  static const String mobileRedirectUrl = 'ekeyless://auth-callback';

  /// Redirect utilizado por los flujos que necesitan
  /// devolver al usuario a la aplicación.
  static String get redirectUrl {
    if (kIsWeb) {
      return Uri.base.origin;
    }

    return mobileRedirectUrl;
  }

  static bool get configured =>
      !url.contains('TU-PROYECTO') && !publishableKey.contains('TU_CLAVE');
}
