import 'dart:math' as math;

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final family in AppThemeFamily.values) {
    for (final brightness in Brightness.values) {
      final theme =
          brightness == Brightness.light
              ? AppThemeFactory.light(family)
              : AppThemeFactory.dark(family);
      final mode = '${family.code} ${brightness.name}';

      testWidgets(
        '$mode plan callouts retain rendered contrast and fit at large text',
        (tester) async {
          const viewport = Size(320, 720);
          await tester.binding.setSurfaceSize(viewport);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final strings = await AppLocalizations.delegate.load(
            const Locale('en'),
          );
          final plansAdded = strings.onboardingPlansAdded(2);
          final plansReady = strings.onboardingPlansReady(2);

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              locale: const Locale('en'),
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2));
                return MediaQuery(data: mediaQuery, child: child!);
              },
              home: Scaffold(
                backgroundColor: theme.colorScheme.surface,
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: OnboardingStyleHarness.card(
                    icon: Icons.fact_check_outlined,
                    title: 'Review your workout plans',
                    subtitle: 'Your plan setup is saved to this profile.',
                    children: [
                      OnboardingStyleHarness.infoCallout(
                        icon: Icons.check_circle_outline,
                        text: plansAdded,
                      ),
                      const SizedBox(height: 12),
                      OnboardingStyleHarness.infoCallout(
                        icon: Icons.check_circle_outline,
                        text: plansReady,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(plansAdded), findsOneWidget);
          expect(find.text(plansReady), findsOneWidget);
          expect(tester.takeException(), isNull);

          final scaffoldCanvas = tester
              .widgetList<Material>(find.byType(Material))
              .singleWhere((material) => material.type == MaterialType.canvas);
          expect(scaffoldCanvas.color, theme.colorScheme.surface);

          _expectRenderedCallout(
            tester,
            text: plansAdded,
            theme: theme,
            scaffoldSurface: scaffoldCanvas.color!,
          );
          _expectRenderedCallout(
            tester,
            text: plansReady,
            theme: theme,
            scaffoldSurface: scaffoldCanvas.color!,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

void _expectRenderedCallout(
  WidgetTester tester, {
  required String text,
  required ThemeData theme,
  required Color scaffoldSurface,
}) {
  final textFinder = find.text(text);
  final decorationAncestors = find.ancestor(
    of: textFinder,
    matching: find.byType(DecoratedBox),
  );
  expect(decorationAncestors, findsNWidgets(2));

  final paintedBoxes = tester.renderObjectList<RenderDecoratedBox>(
    decorationAncestors,
  );
  final calloutBox = paintedBoxes.singleWhere(
    (box) =>
        (box.decoration as BoxDecoration).color ==
        theme.colorScheme.primary.withValues(alpha: 0.12),
  );
  final cardBox = paintedBoxes.singleWhere(
    (box) => !identical(box, calloutBox),
  );
  final calloutDecoration = calloutBox.decoration as BoxDecoration;
  final cardDecoration = cardBox.decoration as BoxDecoration;
  final calloutContext = tester.element(textFinder);

  expect(
    calloutDecoration.color,
    theme.colorScheme.primary.withValues(alpha: 0.12),
  );
  expect(
    calloutDecoration.borderRadius,
    calloutContext.tutorialTokens.inputShape,
  );
  final calloutBorder = calloutDecoration.border! as Border;
  expect(calloutBorder.top.width, 1);
  expect(
    calloutBorder.top.color,
    theme.colorScheme.primary.withValues(alpha: 0.28),
  );

  final cardFill = cardDecoration.color;
  final calloutFill = calloutDecoration.color;
  expect(cardFill, isNotNull);
  expect(calloutFill, isNotNull);

  final renderedCardSurface = Color.alphaBlend(cardFill!, scaffoldSurface);
  final renderedCalloutSurface = Color.alphaBlend(
    calloutFill!,
    renderedCardSurface,
  );
  final renderedBorder = Color.alphaBlend(
    calloutBorder.top.color,
    renderedCardSurface,
  );
  final borderContrast = _contrastRatio(renderedBorder, renderedCardSurface);
  expect(
    borderContrast,
    greaterThan(1.05),
    reason: 'The rendered callout outline should remain distinguishable.',
  );

  final paragraphs = tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  );
  final messageParagraph = paragraphs.singleWhere(
    (paragraph) => paragraph.text.toPlainText() == text,
  );
  final messageForeground = _effectiveForeground(
    messageParagraph,
    DefaultTextStyle.of(calloutContext).style,
  );
  expect(messageForeground, isNotNull);
  expect(
    messageForeground,
    calloutContext.surfaceDecorationTokens.panel.outlined
        ? tonosSecondaryForegroundForSurface(
          calloutContext,
          calloutFill,
          parentSurface: renderedCardSurface,
        )
        : theme.colorScheme.onSurfaceVariant,
  );
  final renderedMessageForeground = Color.alphaBlend(
    messageForeground!,
    renderedCalloutSurface,
  );
  final messageContrast = _contrastRatio(
    renderedMessageForeground,
    renderedCalloutSurface,
  );
  expect(
    messageContrast,
    greaterThanOrEqualTo(4.5),
    reason:
        'Rendered callout text contrast was '
        '${messageContrast.toStringAsFixed(2)}:1 on its composed fill.',
  );

  final iconFinder = find.descendant(
    of:
        find
            .ancestor(of: textFinder, matching: find.byType(DecoratedBox))
            .first,
    matching: find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.check_circle_outline,
    ),
  );
  expect(iconFinder, findsOneWidget);
  final iconParagraph =
      tester
          .renderObjectList<RenderParagraph>(
            find.descendant(of: iconFinder, matching: find.byType(RichText)),
          )
          .single;
  final iconForeground = _effectiveForeground(
    iconParagraph,
    DefaultTextStyle.of(tester.element(iconFinder)).style,
  );
  expect(iconForeground, isNotNull);
  final Color expectedIconForeground =
      calloutContext.surfaceDecorationTokens.panel.outlined
          ? tonosForegroundForSurface(
            calloutContext,
            calloutFill,
            parentSurface: renderedCardSurface,
          )
          : theme.colorScheme.primary;
  expect(iconForeground, expectedIconForeground);
  final renderedIconForeground = Color.alphaBlend(
    iconForeground!,
    renderedCalloutSurface,
  );
  final iconContrast = _contrastRatio(
    renderedIconForeground,
    renderedCalloutSurface,
  );
  expect(
    iconContrast,
    greaterThanOrEqualTo(3),
    reason:
        'Rendered status icon contrast was '
        '${iconContrast.toStringAsFixed(2)}:1 on its composed fill.',
  );
}

Color? _effectiveForeground(RenderParagraph paragraph, TextStyle inherited) {
  final renderedStyle = paragraph.text.style;
  return renderedStyle?.foreground?.color ??
      renderedStyle?.color ??
      inherited.foreground?.color ??
      inherited.color;
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
