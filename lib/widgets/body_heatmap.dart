// file: lib/widgets/body_heatmap.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

// Mapping DB BodyPart.name -> all SVG <path id="..."> strings.
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

class BodyHeatmap extends StatelessWidget {
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

  String _cacheKey() {
    final entries = frequencyMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final encodedEntries = entries
        .map((entry) => '${entry.key}:${entry.value.toStringAsFixed(4)}')
        .join(',');
    return '${_toRgbHex(lowColor)}|${_toRgbHex(highColor)}|$encodedEntries';
  }

  String _renderSvg(String template) {
    final cacheKey = _cacheKey();
    final cachedSvg = _renderCache[cacheKey];
    if (cachedSvg != null) return cachedSvg;

    var svgContent = template;

    svgContent = svgContent.replaceAll(RegExp(r'\sfill="[^"]*"'), '');

    final defaultHex = _toRgbHex(lowColor);

    svgContent = svgContent.replaceAllMapped(
      RegExp(r'(<path\b[^>]*?)(\/?)>'),
      (m) => '${m[1]} fill="$defaultHex"${m[2]}>',
    );

    frequencyMap.forEach((id, freq) {
      final t = freq.clamp(0.0, 1.0);
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
    });

    if (_renderCache.length > 40) {
      _renderCache.remove(_renderCache.keys.first);
    }
    _renderCache[cacheKey] = svgContent;
    return svgContent;
  }

  Widget _buildSvg(String svgContent) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.string(
        svgContent,
        fit: BoxFit.contain,
        width: width,
        height: height,
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
          return SizedBox(
            width: width,
            height: height,
          );
        }
        return _buildSvg(_renderSvg(snapshot.data!));
      },
    );
  }
}
