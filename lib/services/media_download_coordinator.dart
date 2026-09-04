import 'dart:async';
import 'dart:collection';

/// Bounds concurrent optional-media transfers and coalesces duplicate requests.
///
/// Visible media widgets can request the same asset while a catalog is being
/// built. Sharing the in-flight result avoids redundant requests and prevents
/// a burst of thumbnail downloads from competing with interactive app traffic.
class MediaDownloadCoordinator {
  MediaDownloadCoordinator({this.maxConcurrent = 3})
    : assert(maxConcurrent > 0);

  final int maxConcurrent;
  final Map<String, Future<Object?>> _inFlight = {};
  final Queue<_QueuedDownload> _pending = Queue<_QueuedDownload>();
  var _active = 0;

  Future<T> schedule<T>(String key, Future<T> Function() action) {
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }

    final existing = _inFlight[normalizedKey];
    if (existing != null) {
      return existing.then((value) => value as T);
    }

    final completer = Completer<Object?>();
    final future = completer.future;
    _inFlight[normalizedKey] = future;
    _pending.add(
      _QueuedDownload(() async {
        try {
          completer.complete(await action());
        } catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        } finally {
          _active--;
          _inFlight.remove(normalizedKey);
          _pump();
        }
      }),
    );
    _pump();
    return future.then((value) => value as T);
  }

  void _pump() {
    while (_active < maxConcurrent && _pending.isNotEmpty) {
      _active++;
      unawaited(_pending.removeFirst().run());
    }
  }
}

class _QueuedDownload {
  const _QueuedDownload(this.run);

  final Future<void> Function() run;
}
