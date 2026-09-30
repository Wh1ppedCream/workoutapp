import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:env_test/l10n/app_localization_extensions.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/widgets/tonos_bottom_navigation_bar.dart';
import 'package:env_test/widgets/tonos_train_tabs.dart';

void main() {
  testWidgets(
    'Expressive tabs and long French destinations remain actionable in an RTL nonlinear-scale stress case',
    (tester) async {
      const viewport = Size(320, 900);
      const textScaler = _NonlinearReviewScaler();
      expect(textScaler.scale(12) / 12, isNot(textScaler.scale(32) / 32));

      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            locale: const Locale('fr'),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(
                size: viewport,
                textScaler: textScaler,
              ),
              child: const Directionality(
                textDirection: TextDirection.rtl,
                child: _LocalizedNavigationHost(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final hostContext = tester.element(
          find.byType(_LocalizedNavigationHost),
        );
        final strings = AppLocalizations.of(hostContext);
        final trainTabs = find.byType(TonosTrainTabs);
        for (final label in [strings.trainOverviewTab, strings.trainPlansTab]) {
          final semantics = tester
              .getSemantics(find.bySemanticsLabel(label))
              .getSemanticsData();
          expect(
            semantics.hasAction(SemanticsAction.tap),
            isTrue,
            reason: label,
          );
          final target = find.byKey(
            ValueKey(label == strings.trainOverviewTab ? 'overview' : 'plans'),
          );
          final rect = tester.getRect(target);
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
        }
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(strings.trainOverviewTab))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );

        await tester.tap(find.byKey(const ValueKey('plans')));
        await tester.pumpAndSettle();
        expect(
          tester
              .state<_LocalizedNavigationHostState>(
                find.byType(_LocalizedNavigationHost),
              )
              ._selectedTabIndex,
          1,
        );
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(strings.trainPlansTab))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );

        final labels = TabItem.values
            .map((tab) => tab.localizedTitle(strings))
            .toList(growable: false);
        expect(labels, hasLength(11));
        expect(labels, contains('Tableau de bord'));
        expect(labels, contains('Journal nutritionnel'));
        expect(labels, contains('Historique combiné'));

        final navigation = find.byType(TonosBottomNavigationBar);
        expect(navigation, findsOneWidget);
        for (final label in labels) {
          final labelFinder = find.text(label);
          await tester.ensureVisible(labelFinder);
          await tester.pumpAndSettle();

          final semantics = tester
              .getSemantics(find.bySemanticsLabel(label))
              .getSemanticsData();
          expect(
            semantics.hasAction(SemanticsAction.tap),
            isTrue,
            reason: label,
          );

          final destination = find
              .ancestor(of: labelFinder, matching: find.byType(InkWell))
              .first;
          final destinationRect = tester.getRect(destination);
          final visibleHitWidth =
              (destinationRect.right.clamp(0.0, viewport.width) -
                      destinationRect.left.clamp(0.0, viewport.width))
                  .clamp(0.0, viewport.width)
                  .toDouble();
          expect(
            destinationRect.height,
            greaterThanOrEqualTo(48),
            reason: label,
          );
          expect(visibleHitWidth, greaterThanOrEqualTo(48), reason: label);
          final labelRect = tester.getRect(labelFinder);
          expect(labelRect.left, greaterThanOrEqualTo(0), reason: label);
          expect(
            labelRect.right,
            lessThanOrEqualTo(viewport.width),
            reason: label,
          );
        }

        final lastLabel = labels.last;
        await tester.ensureVisible(find.text(lastLabel));
        await tester.pumpAndSettle();
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(lastLabel))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );
        await tester.ensureVisible(find.text(labels.first));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel(labels.first));
        await tester.pumpAndSettle();
        expect(
          tester
              .state<_LocalizedNavigationHostState>(
                find.byType(_LocalizedNavigationHost),
              )
              ._selectedDestinationIndex,
          0,
        );
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(labels.first))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
        );
        expect(tester.takeException(), isNull);
        expect(tester.widget<TonosTrainTabs>(trainTabs).selectedIndex, 1);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}

class _LocalizedNavigationHost extends StatefulWidget {
  const _LocalizedNavigationHost();

  @override
  State<_LocalizedNavigationHost> createState() =>
      _LocalizedNavigationHostState();
}

class _LocalizedNavigationHostState extends State<_LocalizedNavigationHost> {
  var _selectedTabIndex = 0;
  var _selectedDestinationIndex = TabItem.values.length - 1;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final tabs = TabItem.values;
    final items = tabs
        .map(
          (tab) => BottomNavigationBarItem(
            icon: Icon(tab.icon),
            activeIcon: Icon(tab.icon),
            label: tab.localizedTitle(strings),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: TonosTrainTabs.toolbarHeight(
          context,
          overviewLabel: strings.trainOverviewTab,
          plansLabel: strings.trainPlansTab,
        ),
        automaticallyImplyLeading: false,
        title: TonosTrainTabs(
          overviewLabel: strings.trainOverviewTab,
          plansLabel: strings.trainPlansTab,
          selectedIndex: _selectedTabIndex,
          overviewKey: const ValueKey('overview'),
          plansKey: const ValueKey('plans'),
          onChanged: (index) => setState(() => _selectedTabIndex = index),
        ),
      ),
      body: const SizedBox.expand(),
      bottomNavigationBar: TonosBottomNavigationBar(
        items: items,
        currentIndex: _selectedDestinationIndex,
        onTap: (index) => setState(() => _selectedDestinationIndex = index),
      ),
    );
  }
}

/// A monotone nonlinear stress curve; it is not a model of Android's exact
/// nonlinear scaling curve.
class _NonlinearReviewScaler extends TextScaler {
  const _NonlinearReviewScaler();

  @override
  double scale(double fontSize) {
    assert(fontSize >= 0 && fontSize.isFinite);
    return fontSize <= 20 ? fontSize * 2 : 40 + (fontSize - 20) * 0.65;
  }

  @override
  double get textScaleFactor => 2;

  @override
  bool operator ==(Object other) => other is _NonlinearReviewScaler;

  @override
  int get hashCode => 2;
}
