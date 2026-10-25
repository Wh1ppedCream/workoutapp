import 'package:env_test/theme/classic_theme.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/theme/tokens/app_motion_tokens.dart';
import 'package:env_test/theme/widgets/tonos_expressive_navigation_motion.dart';
import 'package:env_test/theme/widgets/tonos_expressive_state_motion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _target = ValueKey('motion-target');

Widget _host(
  Widget child, {
  ThemeData? theme,
  bool disableAnimations = false,
  bool tickerEnabled = true,
}) => MaterialApp(
  theme: theme ?? ExpressiveThemeDefinition.light(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: TickerMode(
        enabled: tickerEnabled,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  ),
);

Widget _pulse(int value, {bool arrival = false}) => TonosExpressiveChangePulse(
  value: value,
  animateOnMount: arrival,
  scale: 1.1,
  child: const SizedBox(key: _target, width: 100, height: 40),
);

void main() {
  for (final brightness in Brightness.values) {
    final theme = brightness == Brightness.light
        ? ExpressiveThemeDefinition.light()
        : ExpressiveThemeDefinition.dark();

    testWidgets(
      'feedback grows without snapping and retargets ${brightness.name}',
      (tester) async {
        await tester.pumpWidget(_host(_pulse(0), theme: theme));
        final resting = tester.getRect(find.byKey(_target));
        await tester.pumpWidget(_host(_pulse(1), theme: theme));
        expect(tester.getRect(find.byKey(_target)), resting);
        await tester.pump(const Duration(milliseconds: 20));
        final growing = tester.getRect(find.byKey(_target));
        expect(growing.width, greaterThan(resting.width));
        expect(growing.width, lessThan(resting.width * 1.1));
        expect(tester.getSize(find.byKey(_target)), const Size(100, 40));

        await tester.pumpWidget(_host(_pulse(2), theme: theme));
        expect(
          tester.getRect(find.byKey(_target)).width,
          closeTo(growing.width, .001),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byKey(_target)), resting);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('arrival feedback settles once ${brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_pulse(0, arrival: true), theme: theme));
      expect(tester.getRect(find.byKey(_target)).width, closeTo(110, .001));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_target)).width, 100);
      await tester.pumpWidget(_host(_pulse(0, arrival: true), theme: theme));
      expect(tester.getRect(find.byKey(_target)).width, 100);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'conditional actions retain shadows and reject exit taps ${brightness.name}',
      (tester) async {
        var taps = 0;
        Widget action(bool visible) => _host(
          TonosExpressiveActionVisibility(
            visible: visible,
            child: SizedBox(
              height: 60,
              width: 180,
              child: FilledButton(
                key: _target,
                onPressed: () => taps++,
                child: const Text('Save Changes'),
              ),
            ),
          ),
          theme: theme,
        );
        await tester.pumpWidget(action(false));
        expect(find.byKey(_target), findsNothing);
        await tester.pumpWidget(action(true));
        await tester.pump(const Duration(milliseconds: 70));
        final clips = tester.widgetList<ClipRect>(
          find.descendant(
            of: find.byType(TonosExpressiveActionVisibility),
            matching: find.byType(ClipRect),
          ),
        );
        expect(clips.map((clip) => clip.clipBehavior), everyElement(Clip.none));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(_target));
        expect(taps, 1);
        await tester.pumpWidget(action(false));
        await tester.tap(find.byKey(_target), warnIfMissed: false);
        expect(taps, 1);
        await tester.pumpAndSettle();
        expect(find.byKey(_target), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final mode in ['reduced', 'effects-off', 'inactive', 'classic']) {
    testWidgets('feedback settles immediately for $mode', (tester) async {
      var theme = ExpressiveThemeDefinition.light();
      if (mode == 'effects-off') {
        theme = theme.copyWith(
          extensions: theme.extensions.values.map(
            (extension) => extension is AppMotionTokens
                ? extension.copyWith(standard: Duration.zero)
                : extension,
          ),
        );
      } else if (mode == 'classic') {
        theme = ClassicThemeDefinition.light();
      }
      Widget frame(int value) => _host(
        _pulse(value, arrival: true),
        theme: theme,
        disableAnimations: mode == 'reduced',
        tickerEnabled: mode != 'inactive',
      );
      await tester.pumpWidget(frame(0));
      expect(tester.getRect(find.byKey(_target)).width, 100);
      await tester.pumpWidget(frame(1));
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.getRect(find.byKey(_target)).width, 100);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'resize keeps a live draft when motion is disabled or re-enabled',
    (tester) async {
      Widget frame(bool reduced, double height) => _host(
        TonosExpressiveResize(
          child: SizedBox(
            height: height,
            width: 220,
            child: const _DraftProbe(),
          ),
        ),
        disableAnimations: reduced,
      );
      await tester.pumpWidget(frame(false, 80));
      final original = tester.state(find.byType(_DraftProbe));
      await tester.enterText(find.byType(TextField), 'Unsaved draft');
      await tester.pumpWidget(frame(true, 120));
      expect(tester.state(find.byType(_DraftProbe)), original);
      expect(find.text('Unsaved draft'), findsOneWidget);
      await tester.pumpWidget(frame(false, 160));
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.state(find.byType(_DraftProbe)), original);
      expect(find.text('Unsaved draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _DraftProbe extends StatefulWidget {
  const _DraftProbe();

  @override
  State<_DraftProbe> createState() => _DraftProbeState();
}

class _DraftProbeState extends State<_DraftProbe> {
  final _text = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(controller: _text);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }
}
