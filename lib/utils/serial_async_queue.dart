/// Runs state-changing operations in call order without letting a failed task
/// poison the next one. Each caller still receives its own result or error.
class SerialAsyncQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
}
