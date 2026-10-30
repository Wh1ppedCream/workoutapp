part of '../exercise_detail_sheet.dart';

class _ExerciseMediaPreviewCard extends StatelessWidget {
  final File? previewFile;
  final Widget? heatmapOverlay;
  final bool expressive;
  final bool catalogBrowserRefinement;
  final VoidCallback onImageTap;
  final VoidCallback onImageLoadFailed;

  const _ExerciseMediaPreviewCard({
    required this.previewFile,
    required this.heatmapOverlay,
    this.expressive = false,
    this.catalogBrowserRefinement = false,
    required this.onImageTap,
    required this.onImageLoadFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: expressive
          ? const ValueKey('exercise-detail-expressive-media-preview')
          : null,
      decoration: BoxDecoration(
        color: expressive
            ? theme.colorScheme.surfaceContainerLow
            : theme.surfaceTokens.mediaPlaceholder,
        borderRadius: expressive
            ? const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(26),
                bottomLeft: Radius.circular(14),
              )
            : theme.mediaTokens.previewShape,
        border: expressive
            ? null
            : Border.all(color: theme.surfaceTokens.mediaOutline),
      ),
      padding: expressive && !catalogBrowserRefinement
          ? const EdgeInsets.all(6)
          : EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        // The Expressive Catalog uses a shorter frame and fills it with a
        // cover crop; other Expressive callers retain the 16:9 preview.
        aspectRatio: catalogBrowserRefinement
            ? 4 / 3
            : expressive
            ? 16 / 9
            : 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              button: previewFile != null,
              label: AppLocalizations.of(context).exerciseDetailOpenImage,
              child: GestureDetector(
                onTap: previewFile == null ? null : onImageTap,
                child: ColoredBox(
                  color: expressive
                      ? catalogBrowserRefinement
                            ? theme.colorScheme.surfaceContainerLow
                            : theme.colorScheme.surfaceContainerLowest
                      : theme.surfaceTokens.media,
                  child: previewFile == null
                      ? Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 36,
                          ),
                        )
                      : Image.file(
                          previewFile!,
                          fit: catalogBrowserRefinement
                              ? BoxFit.cover
                              : expressive
                              ? BoxFit.contain
                              : BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            onImageLoadFailed();
                            return expressive
                                ? Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 36,
                                    ),
                                  )
                                : heatmapOverlay ?? const SizedBox.shrink();
                          },
                        ),
                ),
              ),
            ),
            if (previewFile != null)
              Positioned(
                top: 8,
                left: 8,
                child: catalogBrowserRefinement
                    ? IconButton.filledTonal(
                        tooltip: AppLocalizations.of(context)
                            .exerciseDetailOpenImage,
                        onPressed: onImageTap,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHigh,
                          foregroundColor: theme.colorScheme.onSurface,
                          shape: const CircleBorder(),
                          minimumSize: const Size.square(48),
                        ),
                        icon: const Icon(Icons.zoom_in_rounded),
                      )
                    : IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: MediaViewingColors.indicator,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.zoom_in,
                              color: MediaViewingColors.onIndicator,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
              ),
            if (heatmapOverlay != null)
              Positioned(right: 8, bottom: 8, child: heatmapOverlay!),
          ],
        ),
      ),
    );
  }
}
