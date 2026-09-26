import 'dart:async';

import 'package:env_test/services/media_download_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coalesces duplicate downloads for the same asset', () async {
    final coordinator = MediaDownloadCoordinator();
    final gate = Completer<String>();
    var calls = 0;

    Future<String> download() async {
      calls++;
      return gate.future;
    }

    final first = coordinator.schedule('exercise:42:thumbnail', download);
    final second = coordinator.schedule('exercise:42:thumbnail', download);

    expect(calls, 1);
    gate.complete('cached-file');
    await expectLater(first, completion('cached-file'));
    await expectLater(second, completion('cached-file'));
  });

  test('limits concurrent downloads while queued work continues', () async {
    final coordinator = MediaDownloadCoordinator(maxConcurrent: 2);
    final gates = List.generate(4, (_) => Completer<String>());
    final started = <int>[];

    final downloads = List.generate(
      gates.length,
      (index) => coordinator.schedule('exercise:$index:thumbnail', () async {
        started.add(index);
        return gates[index].future;
      }),
    );

    expect(started, orderedEquals([0, 1]));
    gates[0].complete('zero');
    await Future<void>.delayed(Duration.zero);
    expect(started, orderedEquals([0, 1, 2]));

    gates[1].complete('one');
    gates[2].complete('two');
    await Future<void>.delayed(Duration.zero);
    expect(started, orderedEquals([0, 1, 2, 3]));
    gates[3].complete('three');

    await expectLater(
      Future.wait(downloads),
      completion(['zero', 'one', 'two', 'three']),
    );
  });
}
