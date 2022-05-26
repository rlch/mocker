import 'package:mocker/mocker.dart';
import 'package:test/test.dart';

import 'utils/dummy_classes.dart';

void main() {
  group('constructors', () {
    test('mocks unnamed constructor', () {
      expect(mocker<Unnamed>(), isA<Unnamed>());
    });

    test('mocks empty constructor', () {
      expect(mocker<Empty>(), isA<Empty>());
    });

    test('mocks positionals', () {
      registerGenerator<String>(() => 'good morning kanye');
      expect(mocker<Positionals>().x, 'good morning kanye');
    });

    test('mocks named', () {
      registerGenerator<int>(() => 420);
      expect(mocker<Named>().x, 420);
    });

    test('mocks positionals and named', () {
      bool ping = false;
      registerGenerator<String>(() => (ping = !ping) ? 'ping' : 'pong');
      final m = mocker<PositionalNamed>();
      expect('${m.x} ${m.y}', 'ping pong');
    });
  });
}
