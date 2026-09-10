import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Page-owned camera boundary. Tests provide a fake without platform channels.
abstract class BarcodeScannerSession {
  Stream<String?> get codes;
  bool get hasPermission;
  Widget buildPreview();
  Future<void> start();
  Future<void> stop();
  Future<void> switchCamera();
  Future<void> toggleTorch();
  Future<void> dispose();
}

class MobileBarcodeScannerSession implements BarcodeScannerSession {
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
  );

  @override
  Stream<String?> get codes => _controller.barcodes.map((capture) {
    if (capture.barcodes.isEmpty) return null;
    final first = capture.barcodes.first;
    return first.rawValue ?? first.displayValue;
  });
  @override
  bool get hasPermission => _controller.value.hasCameraPermission;
  @override
  Widget buildPreview() =>
      MobileScanner(controller: _controller, onDetect: (_) {});
  @override
  Future<void> start() => _controller.start();
  @override
  Future<void> stop() => _controller.stop();
  @override
  Future<void> switchCamera() => _controller.switchCamera();
  @override
  Future<void> toggleTorch() => _controller.toggleTorch();
  @override
  Future<void> dispose() => _controller.dispose();
}
