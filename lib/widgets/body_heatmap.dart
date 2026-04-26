// file: lib/widgets/body_heatmap.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class BodyHeatmap extends StatelessWidget {
  static final Future<String> _svgTemplateFuture =
      rootBundle.loadString('assets/body_heatmap.svg');

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgTemplateFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var svgContent = snapshot.data!;

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
      },
    );
  }
}
