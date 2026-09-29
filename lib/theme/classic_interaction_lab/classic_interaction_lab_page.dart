import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'prototype_anchored_menu.dart';
import 'prototype_exercise_expansion.dart';
import 'prototype_primary_action.dart';
import 'prototype_progress_interaction.dart';
import 'prototype_route_flow.dart';
import 'prototype_set_completion.dart';
import 'prototype_train_tabs.dart';

const _compileTimeInteractionPrototypes = bool.fromEnvironment(
  'TONOS_INTERACTION_PROTOTYPES',
);

/// Debug-only, compile-time-gated A/B lab for Classic interaction prototypes.
///
/// Each prototype owns local demo state. This page intentionally has no app
/// navigation item and uses only Tonos and standard Material components.
class ClassicInteractionLabPage extends StatelessWidget {
  const ClassicInteractionLabPage({
    super.key,
    this.enabled = _compileTimeInteractionPrototypes,
  });

  /// Test seam for the compile-time gate. Production callers cannot override
  /// the independent debug-mode guard.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !enabled) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Classic interaction lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: const [
          Text(
            'Local A/B prototypes under the current Classic theme. '
            'No workout or profile data is read or saved.',
          ),
          SizedBox(height: 20),
          PrimaryActionPrototype(),
          SizedBox(height: 20),
          TrainTabsPrototype(),
          SizedBox(height: 20),
          ExerciseExpansionPrototype(),
          SizedBox(height: 20),
          SetCompletionPrototype(),
          SizedBox(height: 20),
          AnchoredMenuPrototype(),
          SizedBox(height: 20),
          ProgressInteractionPrototype(),
          SizedBox(height: 20),
          RouteFlowPrototype(),
        ],
      ),
    );
  }
}
