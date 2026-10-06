# Factory Method — `AutorizacionCreator`

**Archivos fuente:** `lib/patterns/access/autorizacion_creator.dart` y `lib/patterns/access/autorizacion.dart`.

## Clases estrictamente pertenecientes al patrón

```mermaid
classDiagram
    direction LR

    class AutorizacionCreator {
        <<Creator>>
        +Autorizacion crear(perfil)*
    }

    class AutorizacionPermanenteCreator {
        <<Concrete Creator>>
        +Autorizacion crear(perfil)
    }

    class AutorizacionTemporalCreator {
        <<Concrete Creator>>
        +Autorizacion crear(perfil)
    }

    class AutorizacionRecurrenteCreator {
        <<Concrete Creator>>
        +Autorizacion crear(perfil)
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

    AutorizacionCreator <|-- AutorizacionPermanenteCreator
    AutorizacionCreator <|-- AutorizacionTemporalCreator
    AutorizacionCreator <|-- AutorizacionRecurrenteCreator
    Autorizacion <|.. _AutorizacionBase
    _AutorizacionBase <|-- AutorizacionPermanente
    _AutorizacionBase <|-- AutorizacionTemporal
    _AutorizacionBase <|-- AutorizacionRecurrente
    AutorizacionPermanenteCreator ..> AutorizacionPermanente : factory method
    AutorizacionTemporalCreator ..> AutorizacionTemporal : factory method
    AutorizacionRecurrenteCreator ..> AutorizacionRecurrente : factory method
```

## Funcionamiento en el proyecto

`AutorizacionCreator` es el `Creator` y declara el método fábrica `crear(PerfilAcceso perfil)`. Sus tres subclases son los `Concrete Creator`: cada una decide qué producto concreto devuelve.

`AutorizacionPermanenteCreator` crea `AutorizacionPermanente`, `AutorizacionTemporalCreator` crea `AutorizacionTemporal` y `AutorizacionRecurrenteCreator` crea `AutorizacionRecurrente`. Todos los productos se entregan mediante la abstracción `Autorizacion`, que permite que el servicio cliente trabaje con un tipo común.

`PerfilesAccesoService.construirAutorizacion()` selecciona el creador según el tipo de acceso y llama polimórficamente a `crear()`. El hecho de que cada creator use internamente `AutorizacionDirector` y un builder concreto pertenece al patrón Builder y no a la estructura de Factory Method; por eso esas clases no aparecen aquí.

`PerfilAcceso` es el parámetro de entrada del método fábrica, pero no es Creator ni Product. `_AutorizacionBase` se conserva porque es la superclase concreta compartida por los tres productos y forma parte de su jerarquía real de producto.
