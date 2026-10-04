// File: lib/screens/exercise/full_history_screen.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_train_tokens.dart';
import '../../theme/widgets/tonos_surface.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import '../../utils/completed_workout_duration_formatter.dart';
import '../../utils/localized_formatters.dart';
import 'session_detail_screen.dart';

/// Shows every workout session in a simple scrollable list.
class FullHistoryScreen extends StatefulWidget {
  const FullHistoryScreen({super.key});

  @override
  State<FullHistoryScreen> createState() => _FullHistoryScreenState();
}

class _FullHistoryScreenState extends State<FullHistoryScreen> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _repo.fetchWorkoutSessions();
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _repo.fetchWorkoutSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final usesExpressive = context.usesExpressivePresentation;
    return Scaffold(
      appBar: AppBar(title: Text(strings.fullHistoryTitle)),
      body: FutureBuilder<List<WorkoutSession>>(
        future: _sessionsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(strings.fullHistoryLoadError));
          }
          final sessions = snap.data!;
          if (sessions.isEmpty) {
            return Center(child: Text(strings.fullHistoryEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            separatorBuilder: (_, index) {
              if (!usesExpressive) return const Divider(height: 1);
              final sameDay =
                  sessions[index].calendarDay ==
                  sessions[index + 1].calendarDay;
              return SizedBox(height: sameDay ? 0 : 4);
            },
            itemBuilder: (context, i) {
              final s = sessions[i];
              final sameAsPreviousDay =
                  i > 0 && sessions[i - 1].calendarDay == s.calendarDay;
              final sameAsNextDay =
                  i + 1 < sessions.length &&
                  sessions[i + 1].calendarDay == s.calendarDay;
              final dateStr = LocalizedFormatters.date(
                s.calendarDay.toLocalDateTime(),
                Localizations.localeOf(context),
              );
              final duration = formatCompletedWorkoutDuration(
                strings,
                s.duration,
              );
              final semanticLabel = strings.fullHistorySessionSummary(
                dateStr,
                duration,
              );
              Future<void> openSession() async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SessionDetailScreen(s)),
                );
                if (mounted) _reload();
              }

              if (usesExpressive) {
                final surfaces = context.surfaceTokens;
                final tokens = Theme.of(context)
                    .extension<AppExpressiveTrainTokens>()!;
                return MergeSemantics(
                  child: Semantics(
                    button: true,
                    label: semanticLabel,
                    child: TonosSurface(
                      variant: TonosSurfaceVariant.card,
                      color: surfaces.dashboardSection,
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: sameAsPreviousDay || sameAsNextDay ? 2 : 4,
                      ),
                      borderRadius: _expressiveHistoryRowShape(
                        sameAsPreviousDay: sameAsPreviousDay,
                        sameAsNextDay: sameAsNextDay,
                      ),
                      onTap: openSession,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 42,
                              decoration: BoxDecoration(
                                color: tokens.focusSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dateStr,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    duration,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              tonosSecondaryForegroundForSurface(
                                                context,
                                                surfaces.dashboardSection,
                                              ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: tokens.actionSecondaryForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return TonosThemeReadyCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    semanticLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: openSession,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

BorderRadiusGeometry _expressiveHistoryRowShape({
  required bool sameAsPreviousDay,
  required bool sameAsNextDay,
}) {
  if (sameAsPreviousDay && sameAsNextDay) {
    return const BorderRadius.all(Radius.circular(14));
  }
  if (sameAsNextDay) {
    return const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(14),
      bottomLeft: Radius.circular(14),
      bottomRight: Radius.circular(14),
    );
  }
  if (sameAsPreviousDay) {
    return const BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(14),
      bottomLeft: Radius.circular(14),
      bottomRight: Radius.circular(30),
    );
  }
  return ExpressiveTrainShapes.focusInset;
}
