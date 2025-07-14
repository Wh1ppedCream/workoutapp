// file: lib/widgets/body_heatmap.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class BodyHeatmap extends StatelessWidget {
  /// A map from your SVG path-IDs to a normalized 0.0–1.0 frequency.
  final Map<String, double> frequencyMap;

  /// Color you want at intensity=0 and intensity=1.
  final Color lowColor, highColor;
  /// Optional sizing for the heatmap. If omitted, it will size to default SVG dimensions.
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/body_heatmap.svg'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var svgContent = snapshot.data!;

        // 1) strip any existing fill first
svgContent = svgContent.replaceAll(RegExp(r'\sfill="[^"]*"'), '');

// 2) build your lowColor hex once
final r0 = lowColor.red.toRadixString(16).padLeft(2, '0');
final g0 = lowColor.green.toRadixString(16).padLeft(2, '0');
final b0 = lowColor.blue.toRadixString(16).padLeft(2, '0');
final defaultHex = '#$r0$g0$b0';

// 3) default-fill *every* <path>, preserving whether it was self-closing
svgContent = svgContent.replaceAllMapped(
  // group(1) = all attrs up to the slash or end
  // group(2) = optional "/" from self-close
  RegExp(r'(<path\b[^>]*?)(\/?)>'),
  (m) => '${m[1]} fill="$defaultHex"${m[2]}>',
);

// 4) now override your ID’d paths (this will replace the fill you just added)
frequencyMap.forEach((id, freq) {
  final t = freq.clamp(0.0, 1.0);
  final paintColor = Color.lerp(lowColor, highColor, t)!;
  final r = paintColor.red.toRadixString(16).padLeft(2, '0');
  final g = paintColor.green.toRadixString(16).padLeft(2, '0');
  final b = paintColor.blue.toRadixString(16).padLeft(2, '0');
  final hex = '#$r$g$b';

  // this regex finds the path with that id *and* its existing fill
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

        // Constrain sizing via SizedBox; SvgPicture will honor its parent constraints
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
