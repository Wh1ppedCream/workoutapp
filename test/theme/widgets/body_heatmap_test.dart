import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/neo_brutalism_theme.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/widgets/body_heatmap.dart';

void main() {
  test('active fills override the SVG inline black fill style', () {
    const lowColor = Color(0xFF77736B);
    const highColor = Color(0xFF55F0EA);
    final rendered = BodyHeatmap.renderSvgForTesting(
      template: '''
<svg>
  <path style="opacity:0.780142;fill:#000000" id="inactive" />
  <path style="opacity:0.780142;fill:#000000" id="Shoulder_frontal_left" />
</svg>
''',
      frequencyMap: const <String, double>{'Shoulder_frontal_left': 1},
      lowColor: lowColor,
      highColor: highColor,
    );

    expect(rendered, contains('id="inactive"'));
    expect(rendered, contains('style="opacity:0.780142"'));
    expect(rendered, contains('fill="#77736b"'));
    expect(rendered, contains('fill="#55f0ea"'));
    expect(rendered, isNot(contains('fill:#000000')));
    expect(rendered, isNot(contains('/ fill=')));
  });

  test('active anatomy paths are colored in every theme palette', () async {
    const frequencyMap = <String, double>{
      'Shoulder_frontal_left': 1,
      'Shoulder_frontal_right': 1,
      'shoulder_left_back': 1,
      'shoulder_right_rear': 1,
    };
    final templateFile = File('assets/body_heatmap.svg');
    expect(templateFile.existsSync(), isTrue);
    final template = await templateFile.readAsString();
    final modes = <({String name, Color lowColor, Color highColor})>[
      (
        name: 'Classic light',
        lowColor: Color(0xFF9E9E9E),
        highColor: Color(0xFF1565C0),
      ),
      (
        name: 'Classic dark',
        lowColor: Color(0xFFA1A1A1),
        highColor: Color(0xFF1565C0),
      ),
      (
        name: 'Neo light',
        lowColor: Color(0xFF161616),
        highColor: Color(0xFF006A72),
      ),
      (
        name: 'Neo dark',
        lowColor: Color(0xFF77736B),
        highColor: Color(0xFF55F0EA),
      ),
    ];

    for (final mode in modes) {
      final rendered = BodyHeatmap.renderSvgForTesting(
        template: template,
        frequencyMap: frequencyMap,
        lowColor: mode.lowColor,
        highColor: mode.highColor,
      );
      expect(
        rendered,
        isNot(contains('style="opacity:0.780142;fill:#000000"')),
        reason: '${mode.name} must not retain the black inline fill',
      );
      final expectedHex = _rgbHex(mode.highColor);
      for (final id in frequencyMap.keys) {
        final pathPattern = RegExp(
          r'<path\b[^>]*id="' +
              RegExp.escape(id) +
              r'"[^>]*fill="' +
              expectedHex +
              r'"',
          caseSensitive: false,
        );
        expect(
          pathPattern.hasMatch(rendered),
          isTrue,
          reason: '${mode.name} must color active path $id',
        );
      }
    }
  });

  testWidgets('Neo media surfaces keep distinct heatmap colors', (
    tester,
  ) async {
    Color? lowColor;
    Color? highColor;

    await tester.pumpWidget(
      Theme(
        data: NeoBrutalismThemeDefinition.dark(),
        child: Builder(
          builder: (context) {
            final surface = context.surfaceTokens.mediaPlaceholder;
            lowColor = tonosHeatmapLowForSurface(context, surface);
            highColor = tonosHeatmapHighForSurface(context, surface);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(lowColor, const Color(0xFF77736B));
    expect(highColor, const Color(0xFF55F0EA));
    expect(lowColor, isNot(highColor));
  });

  testWidgets('Neo catalog surfaces use a deeper heatmap highlight', (
    tester,
  ) async {
    for (final theme in [
      NeoBrutalismThemeDefinition.light(),
      NeoBrutalismThemeDefinition.dark(),
    ]) {
      Color? highColor;
      await tester.pumpWidget(
        Theme(
          data: theme,
          child: Builder(
            builder: (context) {
              final surface = context.surfaceTokens.catalogSelection;
              highColor = tonosHeatmapHighForSurface(context, surface);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(highColor, const Color(0xFF006A72));
    }
  });
}

String _rgbHex(Color color) {
  String channel(double value) {
    return (value * 255).round().toRadixString(16).padLeft(2, '0');
  }

  return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}';
}
