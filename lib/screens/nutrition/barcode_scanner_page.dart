// File: lib/screens/nutrition/barcode_scanner_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen barcode scanner that returns the first barcode string via Navigator.pop(code).
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  StreamSubscription<Object?>? _sub;
  bool _locked = false; // prevent multiple pops
  bool _torchOn = false;
  CameraFacing _facing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to barcode events from the controller (advanced lifecycle-friendly way)
    _sub = _controller.barcodes.listen(_handleCapture);
    // Start explicitly (safer across platforms)
    unawaited(_controller.start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel());
    _sub = null;
    super.dispose();
    unawaited(_controller.dispose());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only manage lifecycle if permission was already granted
    if (!_controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _sub ??= _controller.barcodes.listen(_handleCapture);
        unawaited(_controller.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_sub?.cancel());
        _sub = null;
        unawaited(_controller.stop());
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void _handleCapture(BarcodeCapture cap) {
    if (_locked) return;
    final barcodes = cap.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (raw == null || raw.trim().isEmpty) return;

    _locked = true;
    Navigator.of(context).pop<String>(raw.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan a barcode'),
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            icon: const Icon(Icons.cameraswitch),
            onPressed: () async {
              _facing = _facing == CameraFacing.back
                  ? CameraFacing.front
                  : CameraFacing.back;
              await _controller.switchCamera();
              setState(() {});
            },
          ),
          IconButton(
            tooltip: _torchOn ? 'Torch off' : 'Torch on',
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
  try {
    await _controller.toggleTorch();
    // Optimistically flip our local UI state; if the device has no torch,
    // toggleTorch() throws and we show a message instead.
    setState(() => _torchOn = !_torchOn);
  } catch (_) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Torch not available on this device')),
      );
    }
  }
},

          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: (_) {}, // handled via controller.barcodes.listen
          ),
          // Simple overlay frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                ),
              ),
            ),
          ),
          // Bottom hint
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              color: const Color(0xAA000000),
              child: const Text(
                'Align the barcode within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
