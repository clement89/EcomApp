class States<T>{
  States._();
  factory States.success(T value) = SuccessState<T>;
  factory States.error(T msg) = ErrorState<T>;
}

class ErrorState<T> extends States<T> {
  ErrorState(this.msg) : super._();
  final T msg;
}

class SuccessState<T> extends States<T> {
  SuccessState(this.value) : super._();
  final T value;
}