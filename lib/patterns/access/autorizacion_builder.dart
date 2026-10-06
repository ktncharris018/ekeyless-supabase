import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'autorizacion.dart';

class AutorizacionBuilder {
  String? _usuarioId;
  String? _candadoKey;
  String? _dispositivoId;
  TipoAccesoPerfil _tipoAcceso = TipoAccesoPerfil.permanente;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  List<int> _diasPermitidos = [];
  int? _horaInicioMinutos;
  int? _horaFinMinutos;
  CanalComunicacion _canalComunicacion = CanalComunicacion.bluetooth;

  AutorizacionBuilder paraUsuario(String usuarioId) {
    _usuarioId = usuarioId.trim();
    return this;
  }

  AutorizacionBuilder paraCandado(String candadoKey) {
    _candadoKey = candadoKey.trim();
    return this;
  }

  AutorizacionBuilder paraDispositivo(String? dispositivoId) {
    _dispositivoId = dispositivoId?.trim();
    return this;
  }

  AutorizacionBuilder tipo(TipoAccesoPerfil tipoAcceso) {
    _tipoAcceso = tipoAcceso;
    return this;
  }

  AutorizacionBuilder desde(DateTime fechaInicio) {
    _fechaInicio = fechaInicio;
    return this;
  }

  AutorizacionBuilder hasta(DateTime? fechaFin) {
    _fechaFin = fechaFin;
    return this;
  }

  AutorizacionBuilder enDias(List<int> diasPermitidos) {
    _diasPermitidos = List<int>.from(diasPermitidos);
    return this;
  }

  AutorizacionBuilder enHorario(int? horaInicioMinutos, int? horaFinMinutos) {
    _horaInicioMinutos = horaInicioMinutos;
    _horaFinMinutos = horaFinMinutos;
    return this;
  }

  AutorizacionBuilder porCanal(CanalComunicacion canalComunicacion) {
    _canalComunicacion = canalComunicacion;
    return this;
  }

  Autorizacion build() {
    final errores = <String>[];
    if ((_usuarioId ?? '').isEmpty) errores.add('El usuario es obligatorio');
    if ((_candadoKey ?? '').isEmpty) errores.add('El candado es obligatorio');
    if (_fechaInicio == null) errores.add('La fecha de inicio es obligatoria');

    final fechaInicio = _fechaInicio;
    final fechaFin = _fechaFin;

    if (fechaInicio != null && fechaFin != null && fechaFin.isBefore(fechaInicio)) {
      errores.add('La fecha final no puede ser anterior a la fecha inicial');
    }

    if (_tipoAcceso == TipoAccesoPerfil.temporal && fechaFin == null) {
      errores.add('El acceso temporal requiere fecha final');
    }

    if (_tipoAcceso == TipoAccesoPerfil.recurrente) {
      if (_diasPermitidos.isEmpty) {
        errores.add('El acceso recurrente requiere al menos un día');
      }
      if (_horaInicioMinutos == null || _horaFinMinutos == null) {
        errores.add('El acceso recurrente requiere horario');
      }
    }

    final horaInicio = _horaInicioMinutos;
    final horaFin = _horaFinMinutos;
    if (horaInicio != null && (horaInicio < 0 || horaInicio > 1439)) {
      errores.add('La hora inicial no es válida');
    }
    if (horaFin != null && (horaFin < 0 || horaFin > 1439)) {
      errores.add('La hora final no es válida');
    }
    if (horaInicio != null && horaFin != null && horaFin <= horaInicio) {
      errores.add('El horario debe tener una hora final posterior a la inicial');
    }

    if (_diasPermitidos.any((day) => day < 1 || day > 7)) {
      errores.add('Los días permitidos deben estar entre 1 y 7');
    }

    if (errores.isNotEmpty) {
      throw ArgumentError(errores.join('. '));
    }

    return Autorizacion(
      usuarioId: _usuarioId!,
      candadoKey: _candadoKey!,
      dispositivoId: _dispositivoId?.isEmpty == true ? null : _dispositivoId,
      tipoAcceso: _tipoAcceso,
      fechaInicio: fechaInicio!,
      fechaFin: fechaFin,
      diasPermitidos: List<int>.unmodifiable(_diasPermitidos),
      horaInicioMinutos: horaInicio,
      horaFinMinutos: horaFin,
      canalComunicacion: _canalComunicacion,
    );
  }
}
