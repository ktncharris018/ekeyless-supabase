abstract class Prototype<T> {
  const Prototype();

  String get prototypeKey;

  T clone();
}

class PrototypeStore<T extends Prototype<T>> {
  PrototypeStore([Iterable<T> prototypes = const []])
    : prototypes = List<T>.from(prototypes);

  final List<T> prototypes;

  void registrar(T prototype) {
    prototypes.removeWhere(
      (item) => item.prototypeKey == prototype.prototypeKey,
    );
    prototypes.add(prototype);
  }

  T getObject(String key) {
    for (final prototype in prototypes) {
      if (prototype.prototypeKey == key) {
        return prototype.clone();
      }
    }

    throw ArgumentError('No existe un prototipo registrado con clave: $key');
  }
}
