// Simple sealed-like result for UI states
abstract class Result<T> {}

class Loading<T> extends Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final Object error;
  Failure(this.error);
}
