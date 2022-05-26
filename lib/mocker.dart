/// Allows configurable runtime mocking of an [Object] at runtime, through reflection.
library mocker;

export 'src/generator.dart' show registerGenerator, registerParamGenerators;
export 'src/mocker.dart' show mocker;
