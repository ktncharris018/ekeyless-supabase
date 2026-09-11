import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ImageStorageRepository {
  Future<String> subirImagen({required List<int> bytes, required String nombreArchivo});
}

class SupabaseImageStorageAdapter implements ImageStorageRepository {
  SupabaseImageStorageAdapter({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _bucket = 'avatars';

  @override
  Future<String> subirImagen({
    required List<int> bytes,
    required String nombreArchivo,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo.jpg';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return _client.storage.from(_bucket).getPublicUrl(path);
  }
}
