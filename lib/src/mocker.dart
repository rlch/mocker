import 'dart:mirrors';

import 'generator.dart';

void main() {
  /// registerMocks({
  ///   PositionalNamed: {
  ///    'x': () => 1,
  ///   },
  /// })
}

/// Mocks a type [T] at runtime using reflection.
///
/// Accepts [paramGenerators], which take precedence over the generators registered globally.
/// They are local in the sense that they're disposed after [T] is instantiated.
T mocker<T>({
  bool mockOptional = true,
  void Function(_LocalRegisterer r)? registerLocalGenerators,
}) {
  var generators = Generators.global();

  if (registerLocalGenerators != null) {
    // Register local generators.
    generators = generators.clone();
    registerLocalGenerators(
      _LocalRegisterer(
        (type, generator) {
          (generators.stores[type] ??= GeneratorStore()).defaultGenerator =
              generator;
        },
        (type, resolverMap) {
          (generators.stores[type] ??= GeneratorStore())
              .resolverMap
              .addAll(resolverMap);
        },
      ),
    );
  }

  dynamic runtimeMocker(Type type, [ParameterMirror? param]) {
    // Trivial case; generator defined for [type].
    if (generators.stores.containsKey(type)) {
      final store = generators.stores[type]!;
      if (param != null) {
        final resolverMap = store.resolverMap;
        for (final e in resolverMap.entries) {
          if (e.key(param)) return e.value;
        }
      }

      final g = store.defaultGenerator;
      if (g != null) {
        return g();
      }
    }

    // Otherwise, try to instantiate [type] using reflection.
    // Find a constructor we can use to instantiate [type], then mock all of its parameters.
    final classMirror = reflectClass(type);
    for (final e in classMirror.declarations.entries) {
      final constructor = e.value;
      if (constructor is! MethodMirror || !constructor.isConstructor) continue;

      bool ok = true;
      final List<dynamic> positionals = [];
      final Map<Symbol, dynamic> named = {};
      for (final param in constructor.parameters) {
        if (param.isOptional && !mockOptional) {
          continue;
        }

        late final dynamic paramInstance;
        try {
          final paramType = param.type.reflectedType;
          paramInstance = runtimeMocker(paramType, param)!;
        } catch (e) {
          print(e);
          ok = false;
          break;
        }

        if (param.isNamed) {
          named[param.simpleName] = paramInstance;
        } else {
          positionals.add(paramInstance);
        }
      }

      if (ok) {
        return classMirror
            .newInstance(
              constructor.constructorName,
              positionals,
              named,
            )
            .reflectee;
      }
    }

    return null;
  }

  return runtimeMocker(T) ??
      (throw StateError('Could not find a suitable constructor for type $T'));
}

class _LocalRegisterer {
  const _LocalRegisterer(this._typeDelegate, this._paramDelegate);

  final void Function(Type type, Generator generator) _typeDelegate;

  final void Function(
    Type type,
    Map<RegisterParamGenerator, Generator> resolverMap,
  ) _paramDelegate;

  void register<T>(
    Generator<T> generator,
  ) =>
      _typeDelegate(T, generator);

  void registerParam<T>(
    ResolverMap<T> resolverMap,
  ) =>
      _paramDelegate(T, resolverMap);
}
