import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'autorizacion.dart';
import 'autorizacion_builder.dart';

abstract class AutorizacionCreator {
  Autorizacion crear(PerfilAcceso perfil);
}

class AutorizacionPermanenteCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return AutorizacionDirector(
      AutorizacionPermanenteBuilder(),
    ).construirObjeto(perfil);
  }
}

class AutorizacionTemporalCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return AutorizacionDirector(
      AutorizacionTemporalBuilder(),
    ).construirObjeto(perfil);
  }
}

class AutorizacionRecurrenteCreator extends AutorizacionCreator {
  @override
  Autorizacion crear(PerfilAcceso perfil) {
    return AutorizacionDirector(
      AutorizacionRecurrenteBuilder(),
    ).construirObjeto(perfil);
  }
}
