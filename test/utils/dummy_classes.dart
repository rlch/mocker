class Unnamed {}

class Empty {
  Empty();
}

class Positionals {
  Positionals(this.x);

  final String x;
}

class Named {
  Named({required this.x});

  final int x;
}

class PositionalNamed {
  final String x, y;

  PositionalNamed(this.x, this.y);
}
