import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tutorial_state_store.dart';
import '../widgets/guided_tutorial_overlay.dart';

Future<void> showGuidedTutorialOnce(
  BuildContext context, {
  required String tutorialId,
  required List<GuidedTutorialStep> steps,
  Duration delay = const Duration(milliseconds: 520),
  bool requireActiveTicker = true,
}) async {
  if (steps.isEmpty) return;

  await Future<void>.delayed(delay);
  if (!context.mounted) return;
  if (requireActiveTicker && !TickerMode.of(context)) return;

  const store = TutorialStateStore();
  final completed = await store.isCompleted(tutorialId);
  if (completed || !context.mounted) return;

  final finished = await GuidedTutorialOverlay.show(context, steps: steps);
  if (finished) {
    await store.markCompleted(tutorialId);
  }
}
