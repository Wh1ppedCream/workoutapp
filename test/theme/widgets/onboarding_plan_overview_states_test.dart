import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:flutter/foundation.dart';
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

      testWidgets('$mode plan overview handles error and reloads to empty', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final failedLoad = Completer<List<Map<String, dynamic>>>();
        final retryLoad = Completer<List<Map<String, dynamic>>>();
        final repository = _PlanOverviewRepository([
          failedLoad.future,
          retryLoad.future,
        ]);
        final refreshToken = ValueNotifier<int>(0);
        addTearDown(refreshToken.dispose);

        await tester.pumpWidget(
          _PlanOverviewApp(
            theme: theme,
            repository: repository,
            refreshToken: refreshToken,
          ),
        );

        final strings = await AppLocalizations.delegate.load(
          const Locale('en'),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(repository.requestedProfileIds, [41]);
        expect(tester.takeException(), isNull);

        failedLoad.completeError(StateError('summary load failed'));
        await tester.pumpAndSettle();
        final errorLabel = strings.onboardingPlanOverviewLoadError;
        expect(find.text(errorLabel), findsOneWidget);
        final errorEvidence = _readRenderedEvidence(
          tester,
          label: errorLabel,
          expectedForeground:
              (context, surface, _) => tonosErrorForSurface(context, surface),
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull);

        refreshToken.value++;
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(repository.requestedProfileIds, [41, 41]);
        expect(tester.takeException(), isNull);

        retryLoad.complete(const <Map<String, dynamic>>[]);
        await tester.pumpAndSettle();
        final emptyLabel = strings.onboardingNoAddedPlans;
        expect(find.text(emptyLabel), findsOneWidget);
        final emptyEvidence = _readRenderedEvidence(
          tester,
          label: emptyLabel,
          expectedForeground:
              (context, surface, parent) => tonosSecondaryForegroundForSurface(
                context,
                surface,
                parentSurface: parent,
              ),
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(repository.focusSetRequests, [<int>[]]);
        expect(tester.takeException(), isNull);

        final evidence = [errorEvidence, emptyEvidence];
        final violations = [
          for (final item in evidence)
            if (item.foreground != item.expectedForeground)
              '${item.label}: rendered foreground ${item.foreground} '
                  'does not match surface owner ${item.expectedForeground}',
          for (final item in evidence)
            if (item.contrastRatio < 4.5)
              '${item.label}: contrast ${item.contrastRatio.toStringAsFixed(2)}:1 '
                  'for foreground ${item.foreground} on '
                  '${item.background} (minimum 4.5:1)',
        ];
        expect(
          violations,
          isEmpty,
          reason:
              '$mode plan overview text ownership/readability:\n'
              '${violations.join('\n')}',
        );
      });
    }
  }
}

class _PlanOverviewApp extends StatelessWidget {
  const _PlanOverviewApp({
    required this.theme,
    required this.repository,
    required this.refreshToken,
  });

  final ThemeData theme;
  final AppRepository repository;
  final ValueListenable<int> refreshToken;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refreshToken,
      builder: (context, token, _) {
        return MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final strings = AppLocalizations.of(context);
              return Scaffold(
                backgroundColor: theme.colorScheme.surface,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: OnboardingStyleHarness.card(
                      icon: Icons.fact_check_outlined,
                      title: strings.onboardingReviewPlansTitle,
                      subtitle: strings.onboardingReviewPlansSubtitle,
                      children: [
                        OnboardingStyleHarness.planOverviewList(
                          repository: repository,
                          profileId: 41,
                          planIds: const {73},
                          refreshToken: token,
                          onChanged: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PlanOverviewRepository extends AppRepository {
  _PlanOverviewRepository(this._summaryResponses);

  final List<Future<List<Map<String, dynamic>>>> _summaryResponses;
  final List<int?> requestedProfileIds = [];
  final List<List<int>> focusSetRequests = [];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({int? profileId}) {
    requestedProfileIds.add(profileId);
    return _summaryResponses.removeAt(0);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async {
    focusSetRequests.add(List<int>.from(presetIds));
    return const <Map<String, dynamic>>[];
  }
}

_RenderedEvidence _readRenderedEvidence(
  WidgetTester tester, {
  required String label,
  required Color Function(BuildContext, Color, Color) expectedForeground,
}) {
  final textFinder = find.text(label);
  final context = tester.element(textFinder);
  final paragraph = tester.renderObject<RenderParagraph>(textFinder);
  final renderedStyle = paragraph.text.style;
  final inheritedStyle = DefaultTextStyle.of(context).style;
  final foreground =
      renderedStyle?.foreground?.color ??
      renderedStyle?.color ??
      inheritedStyle.foreground?.color ??
      inheritedStyle.color;
  expect(foreground, isNotNull, reason: 'No effective foreground for "$label"');

  final cardScroll = find.ancestor(
    of: textFinder,
    matching: find.byType(SingleChildScrollView),
  );
  final cardContainer =
      find
          .descendant(of: cardScroll.first, matching: find.byType(Container))
          .first;
  final cardDecoration =
      tester.widget<Container>(cardContainer).decoration! as BoxDecoration;
  final cardSurface = cardDecoration.color!;
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  final parentSurface =
      scaffold.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  final paintedBackground = Color.alphaBlend(cardSurface, parentSurface);
  final paintedForeground = Color.alphaBlend(foreground!, paintedBackground);

  return _RenderedEvidence(
    label: label,
    foreground: foreground,
    expectedForeground: expectedForeground(context, cardSurface, parentSurface),
    background: paintedBackground,
    contrastRatio: _contrastRatio(paintedForeground, paintedBackground),
  );
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

class _RenderedEvidence {
  const _RenderedEvidence({
    required this.label,
    required this.foreground,
    required this.expectedForeground,
    required this.background,
    required this.contrastRatio,
  });

  final String label;
  final Color foreground;
  final Color expectedForeground;
  final Color background;
  final double contrastRatio;
}
