// File: lib/screens/nutrition/barcode_scanner_page.dart
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
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
    unawaited(_startScanner());
  }

  Future<void> _startScanner() async {
    try {
      await _controller.start();
    } catch (_) {
      // Camera initialization or permission errors are handled by preview state.
    }
  }

  Future<void> _stopScanner() async {
    try {
      await _controller.stop();
    } catch (_) {
      // Ignore stop failures when camera resources are already released.
    }
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
        unawaited(_startScanner());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_sub?.cancel());
        _sub = null;
        unawaited(_stopScanner());
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
    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.nutrition,
      child: Builder(builder: _buildPage),
    );
  }

  Widget _buildPage(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final reticleColor = destination != null
        ? Colors.white
        : Colors.white.withValues(alpha: 0.9);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: destination?.surfacePrimary ?? Colors.black,
        foregroundColor: destination?.onSurfacePrimary ?? Colors.white,
        title: Text(strings.barcodeScannerTitle),
        actions: [
          IconButton(
            tooltip: strings.barcodeSwitchCamera,
            icon: const Icon(Icons.cameraswitch),
            onPressed: () async {
              if (_locked) return;
              try {
                await _controller.switchCamera();
                if (!mounted || _locked) return;
                setState(() {});
              } catch (_) {
                // Single-camera or unsupported devices may reject camera switch.
              }
            },
          ),
          IconButton(
            tooltip: _torchOn
                ? strings.barcodeTorchOff
                : strings.barcodeTorchOn,
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              if (_locked) return;
              try {
                await _controller.toggleTorch();
                if (!mounted || _locked) return;
                // Optimistically flip our local UI state; if the device has no torch,
                // toggleTorch() throws and we show a message instead.
                setState(() => _torchOn = !_torchOn);
              } catch (_) {
                if (!context.mounted || _locked) return;
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
                  border: Border.all(color: reticleColor, width: 2),
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
              color:
                  destination?.surfaceSecondary.withValues(alpha: 0.94) ??
                  const Color(0xAA000000),
              child: Text(
                strings.barcodeAlignHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: destination?.onSurfaceSecondary ?? Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
