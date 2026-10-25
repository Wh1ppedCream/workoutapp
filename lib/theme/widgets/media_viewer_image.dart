import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../tokens/app_media_tokens.dart';
import '../theme_extensions.dart';

/// Shared production route, kept independently testable from repository loading.
Future<void> showMediaImageViewer({
  required BuildContext context,
  required File file,
  required String imageLabel,
  required String zoomHint,
  required String closeLabel,
  required Widget footer,
  bool expressiveFullscreen = false,
  Widget? expressiveFooter,
  Widget? title,
  Future<File?>? detailResolution,
}) => showDialog<void>(
  context: context,
  animationStyle: expressiveFullscreen && context.usesExpressivePresentation
      ? AnimationStyle.noAnimation
      : null,
  useSafeArea: !expressiveFullscreen,
  barrierDismissible: !expressiveFullscreen,
  barrierColor: expressiveFullscreen
      ? MediaViewingColors.backdrop
      : MediaViewingColors.barrier,
  builder: (dialogContext) => expressiveFullscreen
      ? _ExpressiveFullscreenMediaViewer(
          file: file,
          detailResolution: detailResolution,
          imageLabel: imageLabel,
          zoomHint: zoomHint,
          closeLabel: closeLabel,
          footer: expressiveFooter,
          title: title ?? const SizedBox.shrink(),
        )
      : Material(
          color: MediaViewingColors.backdrop,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 64, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: dialogContext.mediaTokens.viewerShape,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4,
                              boundaryMargin: const EdgeInsets.all(48),
                              child: SizedBox.expand(
                                child: MediaViewerImage(
                                  file: file,
                                  label: imageLabel,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            zoomHint,
                            style: const TextStyle(
                              color: MediaViewingColors.hint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        footer,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    tooltip: closeLabel,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
);

class _ExpressiveFullscreenMediaViewer extends StatefulWidget {
  const _ExpressiveFullscreenMediaViewer({
    required this.file,
    required this.detailResolution,
    required this.imageLabel,
    required this.zoomHint,
    required this.closeLabel,
    required this.footer,
    required this.title,
  });

  final File file;
  final Future<File?>? detailResolution;
  final String imageLabel;
  final String zoomHint;
  final String closeLabel;
  final Widget? footer;
  final Widget title;

  @override
  State<_ExpressiveFullscreenMediaViewer> createState() =>
      _ExpressiveFullscreenMediaViewerState();
}

class _ExpressiveFullscreenMediaViewerState
    extends State<_ExpressiveFullscreenMediaViewer> {
  File? _detailFile;
  final TransformationController _imageTransformation =
      TransformationController();
  final Set<int> _imagePointers = <int>{};

  bool get _imageOwnsDrag =>
      _imagePointers.isNotEmpty &&
      (_imagePointers.length > 1 ||
          _imageTransformation.value.getMaxScaleOnAxis() > 1.01);

  void _updateImagePointer(int pointer, {required bool down}) {
    if (_imagePointers.contains(pointer) == down) return;
    setState(() {
      if (down) {
        _imagePointers.add(pointer);
      } else {
        _imagePointers.remove(pointer);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _resolveDetailFile(widget.detailResolution);
  }

  @override
  void didUpdateWidget(covariant _ExpressiveFullscreenMediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detailResolution != widget.detailResolution) {
      _resolveDetailFile(widget.detailResolution);
    }
  }

  @override
  void dispose() {
    _imageTransformation.dispose();
    super.dispose();
  }

  Future<void> _resolveDetailFile(Future<File?>? resolution) async {
    if (resolution == null) return;
    try {
      final file = await resolution;
      if (mounted && file != null) setState(() => _detailFile = file);
    } catch (_) {
      // Keep the immediately available preview when detail media is offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayFile = _detailFile ?? widget.file;
    final image = LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ClipRRect(
            borderRadius: context.mediaTokens.viewerShape,
            child: InteractiveViewer(
              transformationController: widget.footer == null
                  ? null
                  : _imageTransformation,
              constrained: true,
              minScale: 1,
              maxScale: 4,
              boundaryMargin: EdgeInsets.zero,
              child: SizedBox.expand(
                child: Center(
                  child: MediaViewerImage(
                    key: ValueKey(displayFile.path),
                    file: displayFile,
                    label: widget.imageLabel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final zoomableImage = widget.footer == null
        ? image
        : Listener(
            onPointerDown: (event) =>
                _updateImagePointer(event.pointer, down: true),
            onPointerUp: (event) =>
                _updateImagePointer(event.pointer, down: false),
            onPointerCancel: (event) =>
                _updateImagePointer(event.pointer, down: false),
            child: image,
          );
    final zoomHint = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        widget.zoomHint,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: MediaViewingColors.hint),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: MediaViewingColors.backdrop,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: MediaViewingColors.backdrop,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: MediaViewingColors.backdrop,
      ),
      child: Material(
        key: const ValueKey('expressive-media-viewer'),
        color: MediaViewingColors.backdrop,
        child: SizedBox.expand(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: KeyedSubtree(
                              key: const ValueKey(
                                'expressive-media-viewer-title',
                              ),
                              child: widget.title,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: widget.closeLabel,
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            fixedSize: const Size(48, 48),
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.footer == null) ...[
                    Expanded(child: zoomableImage),
                    const SizedBox(height: 8),
                    zoomHint,
                  ] else ...[
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              key: const ValueKey(
                                'expressive-media-viewer-content',
                              ),
                              physics: _imageOwnsDrag
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: constraints.maxWidth
                                        .clamp(0.0, constraints.maxHeight)
                                        .toDouble(),
                                    child: zoomableImage,
                                  ),
                                  const SizedBox(height: 10),
                                  zoomHint,
                                  const SizedBox(height: 12),
                                  widget.footer!,
                                ],
                              ),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full-size viewer can outlive a cached file; keep its error state usable.
class MediaViewerImage extends StatelessWidget {
  const MediaViewerImage({super.key, required this.file, required this.label});
  final File file;
  final String label;

  @override
  Widget build(BuildContext context) => Image.file(
    file,
    fit: BoxFit.contain,
    semanticLabel: label,
    errorBuilder: (context, error, stackTrace) => Semantics(
      label: label,
      image: true,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: MediaViewingColors.onIndicator,
          size: 48,
        ),
      ),
    ),
  );
}
