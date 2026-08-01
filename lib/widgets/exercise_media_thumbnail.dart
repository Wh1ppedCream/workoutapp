import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../services/media_download_preferences.dart';
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
  final bool framed;

  const ExerciseMediaThumbnail({
    super.key,
    required this.definition,
    this.size = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.padding = const EdgeInsets.all(4),
    this.onTap,
    this.framed = true,
  });

  @override
  State<ExerciseMediaThumbnail> createState() => _ExerciseMediaThumbnailState();
}

class _ExerciseMediaThumbnailState extends State<ExerciseMediaThumbnail> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<_ThumbnailData?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
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
      await _repo.ensureExerciseMediaManifestReady();
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
    } on MediaDownloadBlockedException {
      return _ThumbnailData(item: item, wifiOnlyBlocked: true);
    } catch (_) {
      return _ThumbnailData(item: item, failed: true);
    }
  }

  void _retryThumbnail() {
    setState(() {
      _thumbnailFuture = _loadThumbnail();
    });
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
        color: widget.framed ? theme.colorScheme.surfaceContainerHighest : null,
        borderRadius: widget.borderRadius,
        border:
            widget.framed
                ? Border.all(color: theme.colorScheme.outlineVariant)
                : null,
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

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildHeatmapFallback(context),
              if (snapshot.connectionState == ConnectionState.waiting)
                _buildLoadingOverlay(context),
              if (data?.wifiOnlyBlocked == true) _buildWifiOnlyOverlay(context),
              if (data?.failed == true) _buildRetryOverlay(context),
            ],
          );
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

  Widget _buildLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox.square(
        dimension: widget.size * 0.24,
        child: CircularProgressIndicator(
          strokeWidth: 1.6,
          color: theme.colorScheme.primary.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  Widget _buildRetryOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _retryThumbnail,
        child: Container(
          width: widget.size * 0.32,
          height: widget.size * 0.32,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.86),
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Icon(
            Icons.refresh,
            size: widget.size * 0.2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildWifiOnlyOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: widget.size * 0.3,
        height: widget.size * 0.3,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Icon(
          Icons.wifi,
          size: widget.size * 0.18,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThumbnailData {
  final ExerciseMediaItem item;
  final File? file;
  final bool failed;
  final bool wifiOnlyBlocked;

  const _ThumbnailData({
    required this.item,
    this.file,
    this.failed = false,
    this.wifiOnlyBlocked = false,
  });
}
