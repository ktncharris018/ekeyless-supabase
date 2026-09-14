import 'package:ekeyless/models/notificacion_model.dart';
import 'package:ekeyless/repositories/notificacion_repository.dart';

class NotificacionService {
  NotificacionService({NotificacionRepository? repository})
      : _repository = repository ?? SupabaseNotificacionRepository();

  final NotificacionRepository _repository;

  Future<void> registrarNotificacion(NotificacionModel notificacion) =>
      _repository.crear(notificacion);

  Stream<List<NotificacionModel>> obtenerNotificaciones(String receptorId) =>
      _repository.streamPorReceptor(receptorId);

  Future<void> marcarComoLeida(String notificacionId) =>
      _repository.marcarComoLeida(notificacionId);

  Future<void> eliminarNotificacion(String notificacionId) =>
      _repository.eliminar(notificacionId);
}
