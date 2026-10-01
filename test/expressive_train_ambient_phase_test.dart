import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:env_test/theme/widgets/tonos_expressive_motion.dart';

void main() {
  testWidgets(
    'ambient descendants share one live phase and a decorative listener keeps semantics stable',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        Animation<double>? firstPhase;
        Animation<double>? secondPhase;
        final firstSamples = <double>[];
        final secondSamples = <double>[];

        await tester.pumpWidget(
          _ambientHost(
            firstPhase: (phase) => firstPhase = phase,
            secondPhase: (phase) => secondPhase = phase,
            firstSamples: firstSamples,
            secondSamples: secondSamples,
          ),
        );

        expect(firstPhase, isNotNull);
        expect(secondPhase, same(firstPhase));
        expect(firstPhase!.value, 0);
        expect(find.bySemanticsLabel('Weekly focus summary'), findsOneWidget);
        expect(find.bySemanticsLabel('Training emphasis'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 250));

        expect(firstPhase!.value, greaterThan(0));
        expect(secondPhase!.value, firstPhase!.value);
        expect(firstSamples, isNotEmpty);
        expect(secondSamples, isNotEmpty);
        expect(firstSamples.last, firstPhase!.value);
        expect(secondSamples.last, secondPhase!.value);
        // Phase listeners animate paint only; the semantics subtree remains
        // owned by its stable child instead of being duplicated per frame.
        expect(find.bySemanticsLabel('Weekly focus summary'), findsOneWidget);
        expect(find.bySemanticsLabel('Training emphasis'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'reduced motion, Effects Off, and disabled ticker each snap and hold phase at zero',
    (tester) async {
      var reducedMotion = false;
      var effectsOff = false;
      var tickerEnabled = true;
      Animation<double>? phase;

      Widget host() => _ambientHost(
        reducedMotion: reducedMotion,
        effectsOff: effectsOff,
        tickerEnabled: tickerEnabled,
        firstPhase: (value) => phase = value,
      );

      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 250));
      expect(phase!.value, greaterThan(0));

      reducedMotion = true;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);

      reducedMotion = false;
      effectsOff = true;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);

      effectsOff = false;
      tickerEnabled = false;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);

      tickerEnabled = true;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(phase!.value, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'disabled owner and inactive lifecycle snap; reenabling starts a fresh cycle',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      var ownerEnabled = false;
      Animation<double>? phase;

      Widget host() => _ambientHost(
        ownerEnabled: ownerEnabled,
        firstPhase: (value) => phase = value,
      );

      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);

      ownerEnabled = true;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(phase!.value, greaterThan(0));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(phase!.value, 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(phase!.value, greaterThan(0));

      ownerEnabled = false;
      await tester.pumpWidget(host());
      expect(phase!.value, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(phase!.value, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _ambientHost({
  bool reducedMotion = false,
  bool effectsOff = false,
  bool tickerEnabled = true,
  bool ownerEnabled = true,
  required ValueChanged<Animation<double>?> firstPhase,
  ValueChanged<Animation<double>?>? secondPhase,
  List<double>? firstSamples,
  List<double>? secondSamples,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final disableAnimations = reducedMotion || effectsOff;
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: TickerMode(
            enabled: tickerEnabled,
            child: Scaffold(
              body: Center(
                child: TonosExpressiveAmbientMotion(
                  enabled: ownerEnabled,
                  halfCycle: const Duration(seconds: 1),
                  builder: (context, phase, child) => child,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AmbientPhaseConsumer(
                        semanticLabel: 'Weekly focus summary',
                        onPhase: firstPhase,
                        onSample: firstSamples?.add,
                      ),
                      if (secondPhase != null) ...[
                        const SizedBox(width: 8),
                        _AmbientPhaseConsumer(
                          semanticLabel: 'Training emphasis',
                          onPhase: secondPhase,
                          onSample: secondSamples?.add,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _AmbientPhaseConsumer extends StatelessWidget {
  const _AmbientPhaseConsumer({
    required this.semanticLabel,
    required this.onPhase,
    this.onSample,
  });

  final String semanticLabel;
  final ValueChanged<Animation<double>?> onPhase;
  final ValueChanged<double>? onSample;

  @override
  Widget build(BuildContext context) {
    final phase = TonosExpressiveAmbientPhaseScope.maybePhaseOf(context);
    onPhase(phase);
    if (phase == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: phase,
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: const SizedBox.square(dimension: 48),
      ),
      builder: (context, child) {
        onSample?.call(phase.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFE8E1F5),
              const Color(0xFF7E57C2),
              phase.value,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
