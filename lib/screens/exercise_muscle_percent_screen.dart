// File: lib/screens/exercise_muscle_percent_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/safe_failure_localizations.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';
import '../services/safe_failure.dart';
import '../widgets/safe_error_view.dart';

class ExerciseMusclePercentScreen extends StatefulWidget {
  const ExerciseMusclePercentScreen({super.key});

  @override
  State<ExerciseMusclePercentScreen> createState() =>
      _ExerciseMusclePercentScreenState();
}

class _ExerciseMusclePercentScreenState
    extends State<ExerciseMusclePercentScreen> {
  AppRepository get _repo => context.read<AppRepository>();

  List<ExerciseDefinition> _defs = [];
  ExerciseDefinition? _sel;
  List<ExerciseMusclePercent> _entries = [];
  Set<int> _overrides = {}; // muscleIds for which user has saved an override

  bool _isLoading = true;
  bool _isLoadingEntries = false;
  SafeFailure? _failure;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _failure = null;
      });
    }
    try {
      final defs = await _repo.lookupDefsDetailed();
      if (!mounted) return;
      setState(() {
        _defs = defs;
        _sel = defs.isNotEmpty ? defs.first : null;
      });
      if (_sel != null) {
        await _loadEntries(_sel!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _failure = SafeFailure.classify(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadEntries(ExerciseDefinition def) async {
    setState(() => _isLoadingEntries = true);
    try {
      // 1) Compute defaults + overrides merged
      final computed = await _repo.computeMusclePercents(def.id);
      // 2) Fetch explicit overrides
      final saved = await _repo.fetchPercentsForExercise(def.id);
      final overrideIds = saved.map((e) => e.muscleId).toSet();

      if (!mounted || _sel?.id != def.id) return;
      setState(() {
        _entries = computed;
        _overrides = overrideIds;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).musclePercentLoadFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingEntries = false);
      }
    }
  }

  Future<void> _updatePercent(int muscleId, String val) async {
    final parsed = double.tryParse(val) ?? 0.0;
    final def = _sel;
    if (def == null) return;
    try {
      await _repo.setExerciseMuscleHitPercent(def.id, muscleId, parsed);
      await _loadEntries(def);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).musclePercentUpdateFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _resetPercent(int muscleId) async {
    final def = _sel;
    if (def == null) return;
    try {
      await _repo.removeExerciseMusclePercent(def.id, muscleId);
      await _loadEntries(def);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).musclePercentResetFailed(
              safeFailureMessage(AppLocalizations.of(context), e),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_failure != null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.musclePercentTitle)),
        body: SafeErrorView(
          title: strings.safeFailureLoadTitle,
          failure: _failure!,
          onRetry: _initScreen,
        ),
      );
    }
    if (_defs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.musclePercentTitle)),
        body: Center(child: Text(strings.musclePercentNoExercises)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.musclePercentTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<ExerciseDefinition>(
              isExpanded: true,
              value: _sel,
              items:
                  _defs
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
              onChanged: (d) {
                if (d == null) return;
                setState(() {
                  _sel = d;
                  _entries = [];
                  _overrides = {};
                });
                _loadEntries(d);
              },
            ),
          ),
          const Divider(height: 1),
          if (_isLoadingEntries)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child:
                  _entries.isEmpty
                      ? Center(child: Text(strings.musclePercentEmpty))
                      : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (_, i) {
                          final e = _entries[i];
                          final def = _sel!;
                          final muscleName =
                              def.muscles
                                  .firstWhere(
                                    (rm) => rm.muscle.id == e.muscleId,
                                  )
                                  .muscle
                                  .name;
                          final isOverride = _overrides.contains(e.muscleId);

                          return ListTile(
                            title: Text(muscleName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: TextFormField(
                                    initialValue: e.percent.toStringAsFixed(1),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: strings.musclePercentLabel,
                                    ),
                                    onFieldSubmitted:
                                        (v) => _updatePercent(e.muscleId, v),
                                  ),
                                ),
                                if (isOverride)
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: strings.musclePercentRevert,
                                    onPressed: () => _resetPercent(e.muscleId),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }
}
