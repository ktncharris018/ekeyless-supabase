import 'package:ekeyless/repositories/storage_repository.dart';

/// Facade over the image-storage adapter. The registration flow depends on
/// this abstraction, not on a concrete storage vendor.
class SupabaseStorageService {
  SupabaseStorageService({ImageStorageRepository? repository})
      : _repository = repository ?? SupabaseImageStorageAdapter();

  final ImageStorageRepository _repository;

  Future<String> subirImagen({
    required List<int> bytes,
    required String nombreArchivo,
    String? idPublico,
  }) {
    return _repository.subirImagen(
      bytes: bytes,
      nombreArchivo: nombreArchivo,
    );
  }
}
