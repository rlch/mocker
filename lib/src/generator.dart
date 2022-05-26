import 'dart:mirrors';

/// A function that generates an instance of [T].
typedef Generator<T> = T Function();

/// A function that defines whether a certain [Generator] should be used, based off the
/// parameter [p] being generated.
typedef RegisterParamGenerator = bool Function(ParameterMirror p);

typedef ResolverMap<T> = Map<RegisterParamGenerator, Generator<T>>;

/// Registers a [Generator] for a type [T].
void registerGenerator<T>(Generator<T> generator) =>
    (Generators.global().stores[T] ??= GeneratorStore()).defaultGenerator =
        generator;

/// Registers multiple [Generator]s for a type [T].
///
/// The first [Generator] satisfying the associated [RegisterParamGenerator] predicate will be used;
/// as such, the order in which the [Generator]s are registered is important.
///
/// [Generator]'s defined with this function will take precedence over those defined with
/// [registerGenerator].
void registerParamGenerators<T>(
  ResolverMap<T> resolverMap,
) =>
    (Generators.global().stores[T] ??= GeneratorStore())
        .resolverMap
        .addAll(resolverMap);

/// Manages [Generator]s for all types.
class Generators {
  Generators(this.stores);
  factory Generators.global() => _global;
  static final _global = Generators({});

  final Map<Type, GeneratorStore> stores;

  /// Clears all registered [Generator]s
  void clear() => stores.clear();

  Generators clone() => Generators({...stores});
}

/// Stores all the [Generator]s for a given type [T]
class GeneratorStore<T> {
  GeneratorStore();

  final ResolverMap<T> resolverMap = {};
  Generator<T>? defaultGenerator;
}
