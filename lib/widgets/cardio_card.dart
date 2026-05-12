// File: lib/widgets/cardio_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Displays and edits a CardioExercise, including timer controls.
class CardioCard extends StatefulWidget {
  final CardioExercise exercise;
  final bool          readOnlyMode;
  final VoidCallback? onDeleteExercise;
  final VoidCallback? onValueChanged;

  const CardioCard({
    super.key,
    required this.exercise,
    this.readOnlyMode = false,
    this.onDeleteExercise,
    this.onValueChanged,
  });

  @override
  State<CardioCard> createState() => _CardioCardState();
}

class _CardioCardState extends State<CardioCard> {
  late String _note;
  bool _isEditingNote = false;

  late int _cardioMinutes;
  late int _elapsedSeconds;
  late int _secondsLeft;
  Timer? _cardioTimer;

  @override
  void initState() {
    super.initState();
    _syncFromExercise();

  }

  @override
  void dispose() {
    _cardioTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CardioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _cardioTimer?.cancel();
      _syncFromExercise();
    }
  }

  void _syncFromExercise() {
    _note = widget.exercise.cardioNote ?? '';
    _cardioMinutes = widget.exercise.plannedMinutes;
    _elapsedSeconds = widget.exercise.elapsedSeconds;
    _secondsLeft = _remainingSeconds();
  }

  int _remainingSeconds() {
    final remaining = (_cardioMinutes * 60) - _elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  void _startTimer({bool reset = false}) {
    _cardioTimer?.cancel();
    if (reset) {
      _elapsedSeconds = 0;
      widget.exercise.elapsedSeconds = 0;
    }

    _secondsLeft = _remainingSeconds();
    widget.onValueChanged?.call();
    if (_secondsLeft <= 0) {
      setState(() {});
      return;
    }

    _cardioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() {});
        return;
      }

      setState(() {
        _elapsedSeconds++;
        _secondsLeft = _remainingSeconds();
        widget.exercise.elapsedSeconds = _elapsedSeconds;
      });
      widget.onValueChanged?.call();

      if (_secondsLeft <= 0) {
        timer.cancel();
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnlyMode;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Name + Remove Menu ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !readOnly,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'remove') {
                      widget.onDeleteExercise?.call();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove Cardio'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── Note Editor ───
            _isEditingNote
                ? TextFormField(
                    readOnly: readOnly,
                    initialValue: _note,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Note',
                    ),
                    onFieldSubmitted:
                        readOnly ? null : (val) {
                      setState(() {
                        _note = val.trim();
                        _isEditingNote = false;
                      });
                      widget.exercise.cardioNote =
                          _note.isEmpty ? null : _note;
                      widget.onValueChanged?.call();
                    },
                  )
                : (readOnly
                    ? Text(
                        _note.isNotEmpty ? _note : 'Tap to add note',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontStyle: FontStyle.italic),
                      )
                    : GestureDetector(
                        onTap: () =>
                            setState(() => _isEditingNote = true),
                        child: Text(
                          _note.isNotEmpty ? _note : 'Tap to add note',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                      )),
            const SizedBox(height: 16),

            // ─── Minutes Input & GO Button ───
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    key: ValueKey(widget.exercise),
                    initialValue: '$_cardioMinutes',
                    readOnly: readOnly,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Minutes'),
                    onChanged: readOnly ? null : (v) {
                      final mins = int.tryParse(v) ?? 0;
                      setState(() {
                        _cardioMinutes = mins;
                        _secondsLeft = _remainingSeconds();
                      });
                      widget.exercise.plannedMinutes = mins;
                      widget.onValueChanged?.call();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: readOnly ? null : () {
                    _startTimer(reset: true);
                  },
                  child: const Text('GO'),
                ),
              ],
            ),

            // ─── Countdown & Start/Stop Toggle ───
            if (_secondsLeft > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:'
                    '${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                    style:
                        Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_cardioTimer?.isActive ?? false)
                              ? Colors.red
                              : Colors.green,
                    ),
                    onPressed: readOnly ? null : () {
                      if (_cardioTimer?.isActive ?? false) {
                        _cardioTimer!.cancel();
                        setState(() {});
                      } else if (_secondsLeft > 0) {
                        _startTimer();
                      }
                    },
                    child: Text(
                      (_cardioTimer?.isActive ?? false)
                          ? 'Stop'
                          : 'Start',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
