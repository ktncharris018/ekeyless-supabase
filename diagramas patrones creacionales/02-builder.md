# Builder — `AutorizacionBuilder`

**Archivos fuente:** `lib/patterns/access/autorizacion_builder.dart` y `lib/patterns/access/autorizacion.dart`.

## Clases estrictamente pertenecientes al patrón

```mermaid
classDiagram
    direction LR

    class AutorizacionBuilder {
        <<Builder>>
        +AutorizacionBuilder paraUsuario(String usuarioId)
        +AutorizacionBuilder paraCandado(String candadoKey)
        +AutorizacionBuilder paraDispositivo(String? dispositivoId)
        +AutorizacionBuilder tipo(TipoAccesoPerfil tipoAcceso)
        +AutorizacionBuilder desde(DateTime fechaInicio)
        +AutorizacionBuilder hasta(DateTime? fechaFin)
        +AutorizacionBuilder enDias(List~int~ diasPermitidos)
        +AutorizacionBuilder enHorario(int? inicio, int? fin)
        +AutorizacionBuilder porCanal(CanalComunicacion canal)
        +Autorizacion build()
    }

    class _AutorizacionBuilderBase {
        <<Concrete Builder base>>
        -String? _usuarioId
        -String? _candadoKey
        -String? _dispositivoId
        -TipoAccesoPerfil _tipoAcceso
        -DateTime? _fechaInicio
        -DateTime? _fechaFin
        -List~int~ _diasPermitidos
        -int? _horaInicioMinutos
        -int? _horaFinMinutos
        -CanalComunicacion _canalComunicacion
        +Autorizacion build()*
        +void validarComun(TipoAccesoPerfil tipoEsperado)
    }

    class AutorizacionPermanenteBuilder {
        <<Concrete Builder>>
        +Autorizacion build()
    }

    class AutorizacionTemporalBuilder {
        <<Concrete Builder>>
        +Autorizacion build()
    }

    class AutorizacionRecurrenteBuilder {
        <<Concrete Builder>>
        +Autorizacion build()
    }

    class AutorizacionDirector {
        <<Director>>
        +AutorizacionBuilder builder
        +AutorizacionDirector(AutorizacionBuilder builder)
        +Autorizacion construirObjeto(perfil)
    }

    class Autorizacion {
        <<Product>>
        +String usuarioId
        +String candadoKey
        +String? dispositivoId
        +TipoAccesoPerfil tipoAcceso
        +DateTime fechaInicio
        +DateTime? fechaFin
        +List~int~ diasPermitidos
        +int? horaInicioMinutos
        +int? horaFinMinutos
        +CanalComunicacion canalComunicacion
        +String estado
    }

    class _AutorizacionBase {
        <<Product base>>
        +String usuarioId
        +String candadoKey
        +TipoAccesoPerfil tipoAcceso
        +DateTime fechaInicio
        +DateTime? fechaFin
        +String estado
    }

    class AutorizacionPermanente {
        <<Concrete Product>>
        +AutorizacionPermanente(...)
    }

    class AutorizacionTemporal {
        <<Concrete Product>>
        +AutorizacionTemporal(...)
    }

    class AutorizacionRecurrente {
        <<Concrete Product>>
        +AutorizacionRecurrente(...)
    }

    AutorizacionBuilder <|.. _AutorizacionBuilderBase
    _AutorizacionBuilderBase <|-- AutorizacionPermanenteBuilder
    _AutorizacionBuilderBase <|-- AutorizacionTemporalBuilder
    _AutorizacionBuilderBase <|-- AutorizacionRecurrenteBuilder
    Autorizacion <|.. _AutorizacionBase
    _AutorizacionBase <|-- AutorizacionPermanente
    _AutorizacionBase <|-- AutorizacionTemporal
    _AutorizacionBase <|-- AutorizacionRecurrente
    AutorizacionDirector o-- AutorizacionBuilder : dirige
    AutorizacionPermanenteBuilder ..> AutorizacionPermanente : construye
    AutorizacionTemporalBuilder ..> AutorizacionTemporal : construye
    AutorizacionRecurrenteBuilder ..> AutorizacionRecurrente : construye
```

## Funcionamiento en el proyecto

`AutorizacionBuilder` es el `Builder` abstracto. `_AutorizacionBuilderBase` contiene el estado común y la validación compartida; las clases `AutorizacionPermanenteBuilder`, `AutorizacionTemporalBuilder` y `AutorizacionRecurrenteBuilder` son los `Concrete Builder` y producen respectivamente un producto especializado.

`AutorizacionDirector` recibe un builder, establece en orden los datos del perfil y llama a `build()`. El resultado se expone como `Autorizacion`, mientras que las clases concretas `AutorizacionPermanente`, `AutorizacionTemporal` y `AutorizacionRecurrente` representan los productos reales.

El patrón está correctamente aplicado porque separa la construcción paso a paso de la representación final y permite aplicar reglas distintas: el builder temporal exige fecha final y el recurrente exige días y horario. `PerfilAcceso` solo es el objeto de entrada que el director lee; no es un participante estructural del patrón y por eso no se incluye como clase.

Se conservan `_AutorizacionBuilderBase` y `_AutorizacionBase` porque son superclases reales de las clases conformantes: contienen el estado y comportamiento que las implementaciones concretas heredan directamente.
