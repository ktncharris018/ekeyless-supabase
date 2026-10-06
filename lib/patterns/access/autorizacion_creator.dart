import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'autorizacion.dart';
import 'autorizacion_builder.dart';

abstract class AutorizacionCreator {
  Autorizacion crear(PerfilAcceso perfil);

  AutorizacionBuilder _builder(PerfilAcceso perfil) {
    return AutorizacionBuilder()
        .paraUsuario(perfil.usuarioId)
        .paraCandado(perfil.candadoKey)
        .paraDispositivo(perfil.dispositivoId)
        .tipo(perfil.tipoAcceso)
        .desde(perfil.fechaInicio)
        .hasta(perfil.fechaFin)
        .enDias(perfil.diasPermitidos)
        .enHorario(perfil.horaInicioMinutos, perfil.horaFinMinutos)
        .porCanal(perfil.canalComunicacion);
  }
}

class AutorizacionPermanenteCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return _builder(perfil).tipo(TipoAccesoPerfil.permanente).hasta(null).build();
  }
}

class AutorizacionTemporalCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return _builder(perfil).tipo(TipoAccesoPerfil.temporal).build();
  }
}

class AutorizacionRecurrenteCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return _builder(perfil).tipo(TipoAccesoPerfil.recurrente).build();
  }
}

class AutorizacionCreatorFactory {
  const AutorizacionCreatorFactory._();

  static AutorizacionCreator para(TipoAccesoPerfil tipo) {
    switch (tipo) {
      case TipoAccesoPerfil.permanente:
        return AutorizacionPermanenteCreator();
      case TipoAccesoPerfil.temporal:
        return AutorizacionTemporalCreator();
      case TipoAccesoPerfil.recurrente:
        return AutorizacionRecurrenteCreator();
    }
  }
}
