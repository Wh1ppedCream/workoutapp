Future<List<R>> mapWithConcurrency<T, R>(
  List<T> items, {
  required int maxConcurrency,
  required Future<R> Function(T item, int index) mapper,
}) async {
  if (items.isEmpty) return <R>[];

  final results = List<Object?>.filled(items.length, null);
  final concurrency =
      maxConcurrency <= 0
          ? 1
          : (maxConcurrency < items.length ? maxConcurrency : items.length);
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      final index = nextIndex;
      if (index >= items.length) return;
      nextIndex += 1;
      results[index] = await mapper(items[index], index);
    }
  }

  await Future.wait(List.generate(concurrency, (_) => worker()));
  return results.cast<R>();
}
