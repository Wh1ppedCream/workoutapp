import 'package:material_ui/material_ui.dart';

import '../theme_extensions.dart';
import '../widgets/tonos_action.dart';

/// Compares the platform Train-to-Session route with one selective transition.
///
/// Both routes use the same local fixture page. No active-workout provider,
/// repository, or persistence code is involved.
class RouteFlowPrototype extends StatelessWidget {
  const RouteFlowPrototype({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localMediaQuery = MediaQuery.of(context);
    final navigatorMediaQuery = MediaQuery.of(Navigator.of(context).context);
    final sessionMediaQuery = navigatorMediaQuery.copyWith(
      textScaler: localMediaQuery.textScaler,
      disableAnimations: localMediaQuery.disableAnimations,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selectiveDuration = appMotionDuration(
      context,
      context.motionTokens.pageTransition,
    );

    Widget buildSessionPage() => Theme(
      data: theme,
      child: MediaQuery(
        key: const ValueKey('route-flow-session-media-query'),
        data: sessionMediaQuery,
        child: const _LocalSessionPage(),
      ),
    );

    return Card(
      key: const ValueKey('route-flow-prototype'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Train → Session route', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Both choices open the same local Workout Session fixture. '
              'No workout data is read or saved.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TonosAction(
                    key: const ValueKey('route-flow-platform-open'),
                    label: 'Platform route',
                    expand: true,
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(
                          name: '/interaction-lab/platform-session',
                        ),
                        builder: (_) => buildSessionPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TonosAction(
                    key: const ValueKey('route-flow-selective-open'),
                    label: reduceMotion ? 'No-motion route' : 'Selective route',
                    expand: true,
                    onPressed: () => Navigator.of(context).push<void>(
                      _selectiveRoute(
                        duration: selectiveDuration,
                        page: buildSessionPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reduceMotion
                  ? 'Reduced motion resolves the selective route to zero '
                        'duration and removes movement.'
                  : 'The selective route uses a 240 ms fade and a small '
                        'forward slide. Back and destination content stay the same.',
              key: const ValueKey('route-flow-motion-note'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  PageRoute<void> _selectiveRoute({
    required Duration duration,
    required Widget page,
  }) {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: '/interaction-lab/selective-session'),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        if (duration == Duration.zero) return child;

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.035, 0),
          end: Offset.zero,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}

/// A content-identical local stand-in for the current active Session route.
class _LocalSessionPage extends StatelessWidget {
  const _LocalSessionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('route-flow-session-page'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const ValueKey('route-flow-session-back'),
          tooltip: 'Back to Train',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Workout Session'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LocalExerciseCard(
            title: 'Barbell Squat',
            status: '2/2 done',
            complete: true,
          ),
          const SizedBox(height: 12),
          _LocalExerciseCard(
            title: 'Bench Press - Barbell',
            status: '1/2 done',
            complete: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add exercise',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TonosAction(
            key: const ValueKey('route-flow-session-finish'),
            label: 'Finish Workout',
            expand: true,
            onPressed: () => _showLocalCompletionSheet(context),
          ),
        ),
      ),
    );
  }

  void _showLocalCompletionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            key: const ValueKey('route-flow-completion-sheet'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Workout complete',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Local route-flow demo. No session was saved.'),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('route-flow-completion-close'),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalExerciseCard extends StatelessWidget {
  const _LocalExerciseCard({
    required this.title,
    required this.status,
    required this.complete,
  });

  final String title;
  final String status;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  complete ? Icons.check_circle : Icons.fitness_center,
                  color: complete
                      ? theme.semanticColors.workoutCompleted
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                Text(status, style: theme.textTheme.labelMedium),
              ],
            ),
            if (!complete) ...[
              const Divider(height: 20),
              const Row(
                children: [
                  Icon(Icons.check_box_outline_blank, size: 20),
                  SizedBox(width: 8),
                  Text('Set 1'),
                  Spacer(),
                  Text('Weight (lbs)   115'),
                  SizedBox(width: 12),
                  Text('Reps   10'),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Set'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
