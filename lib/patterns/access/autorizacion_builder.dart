import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'autorizacion.dart';

abstract interface class AutorizacionBuilder {
  AutorizacionBuilder paraUsuario(String usuarioId);

  AutorizacionBuilder paraCandado(String candadoKey);

  AutorizacionBuilder paraDispositivo(String? dispositivoId);

  AutorizacionBuilder tipo(TipoAccesoPerfil tipoAcceso);

  AutorizacionBuilder desde(DateTime fechaInicio);

  AutorizacionBuilder hasta(DateTime? fechaFin);

  AutorizacionBuilder enDias(List<int> diasPermitidos);

  AutorizacionBuilder enHorario(int? horaInicioMinutos, int? horaFinMinutos);

  AutorizacionBuilder porCanal(CanalComunicacion canalComunicacion);

  Autorizacion build();
}

abstract class _AutorizacionBuilderBase implements AutorizacionBuilder {
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

  @override
  AutorizacionBuilder paraUsuario(String usuarioId) {
    _usuarioId = usuarioId.trim();
    return this;
  }

  @override
  AutorizacionBuilder paraCandado(String candadoKey) {
    _candadoKey = candadoKey.trim();
    return this;
  }

  @override
  AutorizacionBuilder paraDispositivo(String? dispositivoId) {
    _dispositivoId = dispositivoId?.trim();
    return this;
  }

  @override
  AutorizacionBuilder tipo(TipoAccesoPerfil tipoAcceso) {
    _tipoAcceso = tipoAcceso;
    return this;
  }

  @override
  AutorizacionBuilder desde(DateTime fechaInicio) {
    _fechaInicio = fechaInicio;
    return this;
  }

  @override
  AutorizacionBuilder hasta(DateTime? fechaFin) {
    _fechaFin = fechaFin;
    return this;
  }

  @override
  AutorizacionBuilder enDias(List<int> diasPermitidos) {
    _diasPermitidos = List<int>.from(diasPermitidos);
    return this;
  }

  @override
  AutorizacionBuilder enHorario(int? horaInicioMinutos, int? horaFinMinutos) {
    _horaInicioMinutos = horaInicioMinutos;
    _horaFinMinutos = horaFinMinutos;
    return this;
  }

  @override
  AutorizacionBuilder porCanal(CanalComunicacion canalComunicacion) {
    _canalComunicacion = canalComunicacion;
    return this;
  }

  @override
  Autorizacion build();

  void validarComun(TipoAccesoPerfil tipoEsperado) {
    final errores = <String>[];

    if ((_usuarioId ?? '').isEmpty) errores.add('El usuario es obligatorio');
    if ((_candadoKey ?? '').isEmpty) errores.add('El candado es obligatorio');
    if (_fechaInicio == null) errores.add('La fecha de inicio es obligatoria');
    if (_tipoAcceso != tipoEsperado) {
      errores.add('El builder no corresponde al tipo de acceso seleccionado');
    }

    final fechaInicio = _fechaInicio;
    final fechaFin = _fechaFin;

    if (fechaInicio != null &&
        fechaFin != null &&
        fechaFin.isBefore(fechaInicio)) {
      errores.add('La fecha final no puede ser anterior a la fecha inicial');
    }

    if (tipoEsperado == TipoAccesoPerfil.temporal && fechaFin == null) {
      errores.add('El acceso temporal requiere fecha final');
    }

    if (tipoEsperado == TipoAccesoPerfil.recurrente) {
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
    if (horaInicio != null &&
        horaFin != null &&
        horaFin <= horaInicio) {
      errores.add('El horario debe tener una hora final posterior a la inicial');
    }

    if (_diasPermitidos.any((day) => day < 1 || day > 7)) {
      errores.add('Los días permitidos deben estar entre 1 y 7');
    }

    if (errores.isNotEmpty) {
      throw ArgumentError(errores.join('. '));
    }
  }

  String get usuarioId => _usuarioId!;
  String get candadoKey => _candadoKey!;
  String? get dispositivoId =>
      _dispositivoId?.isEmpty == true ? null : _dispositivoId;
  DateTime get fechaInicio => _fechaInicio!;
  DateTime? get fechaFin => _fechaFin;
  List<int> get diasPermitidos => List<int>.unmodifiable(_diasPermitidos);
  int? get horaInicioMinutos => _horaInicioMinutos;
  int? get horaFinMinutos => _horaFinMinutos;
  CanalComunicacion get canalComunicacion => _canalComunicacion;
}

class AutorizacionPermanenteBuilder extends _AutorizacionBuilderBase {
  @override
  Autorizacion build() {
    validarComun(TipoAccesoPerfil.permanente);
    return AutorizacionPermanente(
      usuarioId: usuarioId,
      candadoKey: candadoKey,
      dispositivoId: dispositivoId,
      fechaInicio: fechaInicio,
      diasPermitidos: diasPermitidos,
      horaInicioMinutos: horaInicioMinutos,
      horaFinMinutos: horaFinMinutos,
      canalComunicacion: canalComunicacion,
    );
  }
}

class AutorizacionTemporalBuilder extends _AutorizacionBuilderBase {
  @override
  Autorizacion build() {
    validarComun(TipoAccesoPerfil.temporal);
    return AutorizacionTemporal(
      usuarioId: usuarioId,
      candadoKey: candadoKey,
      dispositivoId: dispositivoId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin!,
      diasPermitidos: diasPermitidos,
      horaInicioMinutos: horaInicioMinutos,
      horaFinMinutos: horaFinMinutos,
      canalComunicacion: canalComunicacion,
    );
  }
}

class AutorizacionRecurrenteBuilder extends _AutorizacionBuilderBase {
  @override
  Autorizacion build() {
    validarComun(TipoAccesoPerfil.recurrente);
    return AutorizacionRecurrente(
      usuarioId: usuarioId,
      candadoKey: candadoKey,
      dispositivoId: dispositivoId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      diasPermitidos: diasPermitidos,
      horaInicioMinutos: horaInicioMinutos!,
      horaFinMinutos: horaFinMinutos!,
      canalComunicacion: canalComunicacion,
    );
  }
}

class AutorizacionDirector {
  AutorizacionDirector(this.builder);

  final AutorizacionBuilder builder;

  Autorizacion construirObjeto(PerfilAcceso perfil) {
    builder
        .paraUsuario(perfil.usuarioId)
        .paraCandado(perfil.candadoKey)
        .paraDispositivo(perfil.dispositivoId)
        .tipo(perfil.tipoAcceso)
        .desde(perfil.fechaInicio)
        .hasta(perfil.fechaFin)
        .enDias(perfil.diasPermitidos)
        .enHorario(perfil.horaInicioMinutos, perfil.horaFinMinutos)
        .porCanal(perfil.canalComunicacion);

    return builder.build();
  }
}
