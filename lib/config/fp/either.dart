sealed class Either<L, R> {
  T fold<T>(T Function(L l) leftFn, T Function(R r) rightFn) {
    if (this is Left<L, R>) {
      return leftFn((this as Left<L, R>).value);
    } else if (this is Right<L, R>) {
      return rightFn((this as Right<L, R>).value);
    }

    throw Exception('Invalid Either type');
  }

  bool isLeft() => this is Left<L, R>;
  bool isRight() => this is Right<L, R>;

  R getRightOrThrow() {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    throw Exception('Tried to access Right but was Left');
  }

  R getOrElse(R Function() fallback) {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    return fallback();
  }

  L getLeftOrThrow() {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    }
    throw Exception('Tried to access Left but was Right');
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
}
