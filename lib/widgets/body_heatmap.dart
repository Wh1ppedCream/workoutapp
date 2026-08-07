// file: lib/widgets/body_heatmap.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/theme_extensions.dart';

/// Maps database BodyPart.name values to the SVG path IDs that represent them.
///
/// Keep this list in sync with assets/body_heatmap.svg. Most bodyparts appear
/// on both the front and rear silhouettes, so a single app bodypart can map to
/// several path IDs.
const Map<String, List<String>> bodyPartNameToSvgIds = {
  'Neck': ['Neck_frontal', 'neck_rear'],
  'Shoulders': [
    'Shoulder_frontal_left',
    'Shoulder_frontal_right',
    'shoulder_left_back',
    'shoulder_right_rear',
  ],
  'Chest': ['Chest_left', 'Chest_right'],
  'Core': ['Core_front'],
  'Upper Back': ['Upper_Back'],
  'Lower Back': ['lower_back'],
  'Biceps': ['bicep_left', 'Bicep_right'],
  'Triceps': ['tricep_left_back', 'tricep_right_rear'],
  'Forearms': [
    'Forearm_Right_front',
    'forearm_frontal_left',
    'forearm_left_back',
    'forearm_right_rear',
  ],
  'Hips': ['Hip_back_left', 'hip_right_rear'],
  'Hamstrings': ['hamstring_left_back', 'Hamstring_right_back'],
  'Quads': ['Quad_Front_Right', 'Quad_Left_front'],
  'Calves': [
    'Calf_Front_Right',
    'Calf_front_left',
    'Calf_left_back',
    'Calf_right_back',
  ],
};

/// Prebuilt maps for tiny "one bodypart lit up" heatmaps used in lists.
final Map<String, Map<String, double>> singleBodyPartFrequencyMaps = {
  for (final entry in bodyPartNameToSvgIds.entries)
    entry.key: {for (final svgId in entry.value) svgId: 1.0},
};

/// Converts bodypart unit totals into normalized SVG path intensities.
///
/// The largest bodypart gets intensity 1.0 and every other bodypart is relative
/// to it, which lets heatmaps compare focus within a preset/session instead of
/// requiring a universal absolute scale.
Map<String, double> bodyPartFrequencyMapFromNames(
  Map<String, double> bodyPartUnitsByName,
) {
  final maxUnits = bodyPartUnitsByName.values.fold<double>(
    0.0,
    (max, units) => units > max ? units : max,
  );
  if (maxUnits == 0.0) return const <String, double>{};

  final frequencyMap = <String, double>{};
  bodyPartUnitsByName.forEach((bodyPartName, units) {
    final normalized = units / maxUnits;
    for (final id in bodyPartNameToSvgIds[bodyPartName] ?? const <String>[]) {
      frequencyMap[id] = normalized;
    }
  });
  return frequencyMap;
}

/// Small reusable heatmap for a single named bodypart.
class SingleBodyPartHeatmap extends StatelessWidget {
  final String bodyPartName;
  final double size;
  final double padding;
  final Color? lowColor;
  final Color? highColor;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;

  const SingleBodyPartHeatmap({
    super.key,
    required this.bodyPartName,
    this.size = 56,
    this.padding = 4,
    this.lowColor,
    this.highColor,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final svgIds = bodyPartNameToSvgIds[bodyPartName] ?? const <String>[];
    final frequencyMap =
        singleBodyPartFrequencyMaps[bodyPartName] ?? const <String, double>{};
    final contentSize = size - (padding * 2);

    return Semantics(
      label: AppLocalizations.of(context).bodyHeatmapSemantics(bodyPartName),
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
        ),
        child:
            svgIds.isEmpty
                ? Icon(
                  Icons.accessibility_new,
                  size: contentSize.clamp(18, 28).toDouble(),
                )
                : BodyHeatmap(
                  frequencyMap: frequencyMap,
                  lowColor: lowColor ?? colors.historySummaryHeatmapLow!,
                  highColor: highColor ?? colors.historySummaryHeatmapHigh!,
                  width: contentSize,
                  height: contentSize,
                ),
      ),
    );
  }
}

/// Renders the shared body heatmap SVG with selected bodypart path fills.
///
/// The template SVG is loaded once, and rendered SVG strings are cached by color
/// and bucketed intensity map. That keeps repeated heatmaps cheap enough to use
/// in preset bars, history summaries, and detail cards.
class BodyHeatmap extends StatelessWidget {
  static const int _maxRenderCacheEntries = 80;
  static const int _frequencyBuckets = 20;
  static Future<String>? _svgTemplateFuture;
  static String? _svgTemplate;
  static final Map<String, String> _renderCache = <String, String>{};

  final Map<String, double> frequencyMap;
  final Color lowColor;
  final Color highColor;
  final double? width;
  final double? height;

  const BodyHeatmap({
    super.key,
    required this.frequencyMap,
    this.lowColor = const Color(0xFFCFE4FF),
    this.highColor = const Color(0xFF0033BB),
    this.width,
    this.height,
  });

  static Future<String> _loadSvgTemplate() {
    final cachedTemplate = _svgTemplate;
    if (cachedTemplate != null) return Future.value(cachedTemplate);

    return _svgTemplateFuture ??= rootBundle
        .loadString('assets/body_heatmap.svg')
        .then((template) {
          _svgTemplate = template;
          return template;
        });
  }

  static Future<void> preload() async {
    await _loadSvgTemplate();
  }

  static String _toRgbHex(Color color) {
    String channelHex(double channel) {
      return (channel * 255)
          .round()
          .clamp(0, 255)
          .toInt()
          .toRadixString(16)
          .padLeft(2, '0');
    }

    final r = channelHex(color.r);
    final g = channelHex(color.g);
    final b = channelHex(color.b);
    return '#${r.padLeft(2, '0')}${g.padLeft(2, '0')}${b.padLeft(2, '0')}';
  }

  static double _bucketFrequency(double value) {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    if (clamped <= 0.0) return 0.0;
    if (clamped >= 1.0) return 1.0;
    return (clamped * _frequencyBuckets).round() / _frequencyBuckets;
  }

  List<MapEntry<String, double>> _normalizedFrequencyEntries() {
    return frequencyMap.entries
        .map((entry) => MapEntry(entry.key, _bucketFrequency(entry.value)))
        .where((entry) => entry.value > 0.0)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  String _cacheKey(List<MapEntry<String, double>> entries) {
    final encodedEntries = entries
        .map((entry) => '${entry.key}:${entry.value.toStringAsFixed(2)}')
        .join(',');
    return '${_toRgbHex(lowColor)}|${_toRgbHex(highColor)}|$encodedEntries';
  }

  String _renderSvg(String template) {
    final entries = _normalizedFrequencyEntries();
    final cacheKey = _cacheKey(entries);
    final cachedSvg = _renderCache.remove(cacheKey);
    if (cachedSvg != null) {
      _renderCache[cacheKey] = cachedSvg;
      return cachedSvg;
    }

    var svgContent = template;

    svgContent = svgContent.replaceAll(RegExp(r'\sfill="[^"]*"'), '');

    final defaultHex = _toRgbHex(lowColor);

    svgContent = svgContent.replaceAllMapped(
      RegExp(r'(<path\b[^>]*?)(\/?)>'),
      (m) => '${m[1]} fill="$defaultHex"${m[2]}>',
    );

    for (final entry in entries) {
      final id = entry.key;
      final t = entry.value;
      final paintColor = Color.lerp(lowColor, highColor, t)!;
      final hex = _toRgbHex(paintColor);

      final re = RegExp(
        r'(<path\b[^>]*\bid="' +
            RegExp.escape(id) +
            r'"[^>]*?)\sfill="[^"]*"([^>]*)(\/?)>',
        caseSensitive: false,
      );

      svgContent = svgContent.replaceAllMapped(
        re,
        (m) => '${m[1]} fill="$hex"${m[2]}${m[3]}>',
      );
    }

    _renderCache[cacheKey] = svgContent;
    while (_renderCache.length > _maxRenderCacheEntries) {
      _renderCache.remove(_renderCache.keys.first);
    }
    return svgContent;
  }

  Widget _buildSvg(String svgContent) {
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: SvgPicture.string(
          svgContent,
          fit: BoxFit.contain,
          width: width,
          height: height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedTemplate = _svgTemplate;
    if (cachedTemplate != null) {
      return _buildSvg(_renderSvg(cachedTemplate));
    }

    return FutureBuilder<String>(
      future: _loadSvgTemplate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: width, height: height);
        }
        return _buildSvg(_renderSvg(snapshot.data!));
      },
    );
  }
}
