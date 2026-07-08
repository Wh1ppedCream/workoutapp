import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import 'body_heatmap.dart';

/// Shows cloud/cached exercise media when available, otherwise falls back to
/// the local anatomy heatmap so catalog rows remain useful offline.
class ExerciseMediaThumbnail extends StatefulWidget {
  final ExerciseDefinition definition;
  final double size;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const ExerciseMediaThumbnail({
    super.key,
    required this.definition,
    this.size = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.padding = const EdgeInsets.all(4),
    this.onTap,
  });

  @override
  State<ExerciseMediaThumbnail> createState() => _ExerciseMediaThumbnailState();
}

class _ExerciseMediaThumbnailState extends State<ExerciseMediaThumbnail> {
  late final AppRepository _repo;
  late Future<_ThumbnailData?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _repo = AppRepository();
    _thumbnailFuture = _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant ExerciseMediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.id != widget.definition.id) {
      _thumbnailFuture = _loadThumbnail();
    }
  }

  Future<_ThumbnailData?> _loadThumbnail() async {
    try {
      await _repo.syncBundledExerciseMediaManifest();
    } catch (_) {
      // Exercise media is optional and should never block catalog rendering.
    }

    final item = await _repo.fetchPrimaryExerciseMedia(widget.definition.id);
    if (item == null) return null;

    final cached = await _repo.cachedExerciseMediaFile(item, thumbnail: true);
    if (cached != null) {
      unawaited(_repo.markExerciseMediaAccessed(item));
      return _ThumbnailData(item: item, file: cached);
    }

    if (!_looksLikeImage(item.thumbnailUrl ?? item.remoteUrl)) {
      return _ThumbnailData(item: item);
    }

    try {
      final downloaded = await _repo.cacheExerciseMedia(item, thumbnail: true);
      return _ThumbnailData(item: item, file: downloaded);
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: widget.borderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<_ThumbnailData?>(
        future: _thumbnailFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data?.file != null) {
            return ClipRRect(
              borderRadius: widget.borderRadius,
              child: Image.file(data!.file!, fit: BoxFit.cover),
            );
          }

          return _buildHeatmapFallback(context);
        },
      ),
    );

    if (widget.onTap == null) return child;
    return InkWell(
      borderRadius: widget.borderRadius,
      onTap: widget.onTap,
      child: child,
    );
  }

  Widget _buildHeatmapFallback(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final heatmapFrequencyMap = bodyPartFrequencyMapFromNames({
      for (final bodyPart in widget.definition.bodyParts) bodyPart.name: 1.0,
    });

    if (heatmapFrequencyMap.isEmpty) {
      return Icon(
        Icons.accessibility_new,
        color: theme.colorScheme.primary,
        size: widget.size * 0.45,
      );
    }

    final heatmapSize = widget.size - widget.padding.horizontal;
    return BodyHeatmap(
      frequencyMap: heatmapFrequencyMap,
      lowColor: colors.historySummaryHeatmapLow!,
      highColor: colors.historySummaryHeatmapHigh!,
      width: heatmapSize,
      height: heatmapSize,
    );
  }
}

class _ThumbnailData {
  final ExerciseMediaItem item;
  final File? file;

  const _ThumbnailData({required this.item, this.file});
}
