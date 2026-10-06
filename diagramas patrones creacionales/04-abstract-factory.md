# Abstract Factory — `LockCommunicationFactory`

**Archivo fuente:** `lib/patterns/access/communication_factory.dart`.

## Clases estrictamente pertenecientes al patrón

```mermaid
classDiagram
    direction LR

    class LockCommunicationFactory {
        <<Abstract Factory>>
        +LockScanner createScanner()*
        +LockConnector createConnector()*
        +LockCommandChannel createCommandChannel()*
    }

    class BluetoothCommunicationFactory {
        <<Concrete Factory>>
        -BleLockGateway _gateway
        +BluetoothCommunicationFactory(BleLockGateway gateway)
        +LockScanner createScanner()
        +LockConnector createConnector()
        +LockCommandChannel createCommandChannel()
    }

    class NfcCommunicationFactory {
        <<Concrete Factory>>
        +LockScanner createScanner()
        +LockConnector createConnector()
        +LockCommandChannel createCommandChannel()
    }

    class LockScanner {
        <<Abstract Product A>>
        +escanear(timeout)
    }

    class BluetoothScanner {
        <<Concrete Product A1>>
        -BleLockGateway _gateway
        +escanear(timeout)
    }

    class NfcScanner {
        <<Concrete Product A2>>
        +escanear(timeout)
    }

    class LockConnector {
        <<Abstract Product B>>
        +conectar(device)
    }

    class BluetoothConnector {
        <<Concrete Product B1>>
        -BleLockGateway _gateway
        +conectar(device)
    }

    class NfcConnector {
        <<Concrete Product B2>>
        +conectar(device)
    }

    class LockCommandChannel {
        <<Abstract Product C>>
        +enviar(device, comando)
    }

    class BluetoothCommandChannel {
        <<Concrete Product C1>>
        -BleLockGateway _gateway
        +enviar(device, comando)
    }

    class NfcCommandChannel {
        <<Concrete Product C2>>
        +enviar(device, comando)
    }

    LockCommunicationFactory <|.. BluetoothCommunicationFactory
    LockCommunicationFactory <|.. NfcCommunicationFactory
    LockScanner <|.. BluetoothScanner
    LockScanner <|.. NfcScanner
    LockConnector <|.. BluetoothConnector
    LockConnector <|.. NfcConnector
    LockCommandChannel <|.. BluetoothCommandChannel
    LockCommandChannel <|.. NfcCommandChannel
    BluetoothCommunicationFactory ..> BluetoothScanner : crea familia Bluetooth
    BluetoothCommunicationFactory ..> BluetoothConnector : crea familia Bluetooth
    BluetoothCommunicationFactory ..> BluetoothCommandChannel : crea familia Bluetooth
    NfcCommunicationFactory ..> NfcScanner : crea familia NFC
    NfcCommunicationFactory ..> NfcConnector : crea familia NFC
    NfcCommunicationFactory ..> NfcCommandChannel : crea familia NFC
```

## Funcionamiento en el proyecto

`LockCommunicationFactory` es la `Abstract Factory` y declara tres métodos de creación para tres familias de productos relacionados: escaneo, conexión y envío de comandos.

`BluetoothCommunicationFactory` es una `Concrete Factory` que crea la familia Bluetooth (`BluetoothScanner`, `BluetoothConnector` y `BluetoothCommandChannel`). `NfcCommunicationFactory` crea la familia NFC (`NfcScanner`, `NfcConnector` y `NfcCommandChannel`). Cada producto concreto implementa la interfaz abstracta de su misma categoría.

La estructura cumple Abstract Factory porque el cliente puede trabajar con `LockCommunicationFactory` y obtener una familia coherente sin instanciar directamente sus productos concretos. Bluetooth es la familia operativa; NFC está definida como extensión arquitectónica y sus operaciones aún lanzan `UnsupportedError`.

`LockDevice` y `BluetoothLockDevice` no aparecen porque son tipos de datos usados por los productos, no productos creados por ninguno de los tres métodos de la fábrica. `BleLockGateway` es una dependencia de infraestructura de los productos Bluetooth y `LockCommunicationFactoryProvider` es un selector auxiliar; ninguno forma parte de los roles estructurales de Abstract Factory.
