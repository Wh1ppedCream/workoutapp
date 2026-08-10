import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../repositories/app_repository.dart';
import '../services/media_download_preferences.dart';

/// Displays optional cloud media for a stable equipment, bodypart, or muscle
/// definition. The caller supplies a local semantic fallback so an incomplete
/// manifest, offline state, or blocked download never leaves a blank tile.
class SharedEntityMediaThumbnail extends StatefulWidget {
  final SharedMediaEntityType entityType;
  final int entityId;
  final double size;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double imageScale;
  final BoxFit imageFit;
  final Widget Function(BuildContext context, double contentSize)
  fallbackBuilder;
  final VoidCallback? onTap;

  const SharedEntityMediaThumbnail({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.fallbackBuilder,
    this.size = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.padding = const EdgeInsets.all(3),
    this.backgroundColor,
    this.borderColor,
    this.imageScale = 1,
    this.imageFit = BoxFit.cover,
    this.onTap,
  });

  @override
  State<SharedEntityMediaThumbnail> createState() =>
      _SharedEntityMediaThumbnailState();
}

class _SharedEntityMediaThumbnailState
    extends State<SharedEntityMediaThumbnail> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<_SharedThumbnailData?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant SharedEntityMediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entityType != widget.entityType ||
        oldWidget.entityId != widget.entityId) {
      _thumbnailFuture = _loadThumbnail();
    }
  }

  Future<_SharedThumbnailData?> _loadThumbnail() async {
    try {
      await _repo.ensureSharedMediaManifestReady();
    } catch (_) {
      // Shared media is optional and the provided fallback remains useful.
    }

    final item = await _repo.fetchPrimarySharedMedia(
      widget.entityType,
      widget.entityId,
    );
    if (item == null) return null;

    final cached = await _repo.cachedSharedMediaFile(item, thumbnail: true);
    if (cached != null) {
      unawaited(_recordMediaAccess(item));
      return _SharedThumbnailData(item: item, file: cached);
    }

    if (!_looksLikeImage(item.thumbnailUrl ?? item.remoteUrl)) {
      return _SharedThumbnailData(item: item);
    }

    try {
      final downloaded = await _repo.cacheSharedMedia(item, thumbnail: true);
      return _SharedThumbnailData(item: item, file: downloaded);
    } on MediaDownloadBlockedException {
      return _SharedThumbnailData(item: item, wifiOnlyBlocked: true);
    } catch (_) {
      return _SharedThumbnailData(item: item, failed: true);
    }
  }

  Future<void> _recordMediaAccess(SharedMediaItem item) async {
    try {
      await _repo.markSharedMediaAccessed(item);
    } catch (_) {
      // Access timestamps are cache bookkeeping and must not affect rendering.
    }
  }

  bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  void _retry() {
    setState(() => _thumbnailFuture = _loadThumbnail());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentSize = widget.size - widget.padding.horizontal;
    final child = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: widget.borderRadius,
        border:
            widget.borderColor == null
                ? null
                : Border.all(color: widget.borderColor!),
      ),
      child: FutureBuilder<_SharedThumbnailData?>(
        future: _thumbnailFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data?.file != null) {
            return Transform.scale(
              scale: widget.imageScale,
              child: Image.file(
                data!.file!,
                fit: widget.imageFit,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              widget.fallbackBuilder(context, contentSize),
              if (snapshot.connectionState == ConnectionState.waiting)
                _loadingOverlay(context),
              if (data?.wifiOnlyBlocked == true) _wifiOverlay(context),
              if (data?.failed == true) _retryOverlay(context),
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

  Widget _loadingOverlay(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox.square(
        dimension: widget.size * 0.22,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.72),
        ),
      ),
    );
  }

  Widget _wifiOverlay(BuildContext context) {
    return _statusCircle(context, Icons.wifi);
  }

  Widget _retryOverlay(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _retry,
      child: _statusCircle(context, Icons.refresh),
    );
  }

  Widget _statusCircle(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: widget.size * 0.3,
        height: widget.size * 0.3,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.84),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Icon(
          icon,
          size: widget.size * 0.18,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SharedThumbnailData {
  final SharedMediaItem item;
  final File? file;
  final bool failed;
  final bool wifiOnlyBlocked;

  const _SharedThumbnailData({
    required this.item,
    this.file,
    this.failed = false,
    this.wifiOnlyBlocked = false,
  });
}
