import 'dart:async';

import 'package:env_test/utils/serial_async_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'queued operations complete in order and retain typed results',
    () async {
      final queue = SerialAsyncQueue();
      final gate = Completer<void>();
      final events = <int>[];
      final first = queue.run(() async {
        events.add(1);
        await gate.future;
        events.add(2);
        return 'first';
      });
      final second = queue.run(() async {
        events.add(3);
        return 7;
      });
      await Future<void>.delayed(Duration.zero);
      expect(events, [1]);
      gate.complete();
      expect(await first, 'first');
      expect(await second, 7);
      expect(events, [1, 2, 3]);
    },
  );
  test('failed operations reach callers while later work still runs', () async {
    final queue = SerialAsyncQueue();
    final failure = queue.run<void>(() {
      throw StateError('failed');
    });
    final next = queue.run(() async => 'next');
    await expectLater(failure, throwsStateError);
    expect(await next, 'next');
  });
}
