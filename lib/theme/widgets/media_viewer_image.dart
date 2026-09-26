import 'dart:io';
import 'package:flutter/material.dart';
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
}) => showDialog<void>(
  context: context,
  barrierColor: MediaViewingColors.barrier,
  builder:
      (dialogContext) => Material(
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
    errorBuilder:
        (context, error, stackTrace) => Semantics(
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
