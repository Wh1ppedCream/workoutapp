// File: lib/screens/nutrition/barcode_scanner_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/barcode_scanner_session.dart';

import '../../l10n/generated/app_localizations.dart';

/// Full-screen barcode scanner that returns the first barcode string via Navigator.pop(code).
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, this.session});

  /// When supplied, ownership transfers to this page, including disposal.
  final BarcodeScannerSession? session;

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with WidgetsBindingObserver {
  late final BarcodeScannerSession _controller;
  StreamSubscription<String?>? _sub;
  bool _locked = false; // prevent multiple pops
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.session ?? MobileBarcodeScannerSession();
    WidgetsBinding.instance.addObserver(this);

    // Listen to barcode events from the controller (advanced lifecycle-friendly way)
    _sub = _controller.codes.listen(_handleCapture);
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
    if (!_controller.hasPermission || _locked) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _sub ??= _controller.codes.listen(_handleCapture);
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

  void _handleCapture(String? raw) {
    if (!mounted || _locked || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    if (raw == null || raw.trim().isEmpty) return;

    _locked = true;
    Navigator.of(context).pop<String>(raw.trim());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(strings.barcodeScannerTitle),
        actions: [
          IconButton(
            tooltip: strings.barcodeSwitchCamera,
            icon: const Icon(Icons.cameraswitch),
            onPressed: () async {
              await _controller.switchCamera();
              if (!mounted) return;
              setState(() {});
            },
          ),
          IconButton(
            tooltip:
                _torchOn ? strings.barcodeTorchOff : strings.barcodeTorchOn,
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              try {
                await _controller.toggleTorch();
                if (!mounted) return;
                // Optimistically flip our local UI state; if the device has no torch,
                // toggleTorch() throws and we show a message instead.
                setState(() => _torchOn = !_torchOn);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.barcodeTorchUnavailable)),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          _controller.buildPreview(),
          // Simple overlay frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
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
              child: Text(
                strings.barcodeAlignHint,
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
