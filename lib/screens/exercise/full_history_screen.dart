// File: lib/screens/exercise/full_history_screen.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../providers/unit_preference_provider.dart';
import '../../repositories/app_repository.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../theme/tokens/app_expressive_train_tokens.dart';
import '../../theme/widgets/app_expressive_destination_theme.dart';
import '../../theme/widgets/tonos_surface.dart';
import '../../theme/widgets/tonos_theme_ready.dart';
import '../../utils/completed_workout_duration_formatter.dart';
import '../../utils/localized_formatters.dart';
import '../../utils/weight_unit_formatter.dart';
import 'session_detail_screen.dart';

/// Shows every workout session in a simple scrollable list.
class FullHistoryScreen extends StatefulWidget {
  const FullHistoryScreen({super.key});

  @override
  State<FullHistoryScreen> createState() => _FullHistoryScreenState();
}

class _FullHistoryScreenState extends State<FullHistoryScreen> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<WorkoutReportSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessionsNewestFirst();
  }

  Future<List<WorkoutReportSession>> _fetchSessionsNewestFirst() async {
    // The shared report query is ordered oldest-first; the history screen has
    // always presented newest dates and sessions first.
    final sessions = await _repo.fetchWorkoutReportSessions();
    return sessions.reversed.toList(growable: false);
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _fetchSessionsNewestFirst();
    });
  }

  @override
  Widget build(BuildContext context) => _buildScopedScreen(context);

  Widget _buildScopedScreen(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final usesExpressive = context.usesExpressivePresentation;
    final weightUnit = usesExpressive
        ? context.watch<UnitPreferenceProvider>().weightUnit
        : WeightUnit.pounds;
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();

    return Scaffold(
      backgroundColor: destinationTokens?.pageCanvas,
      appBar: AppBar(title: Text(strings.fullHistoryTitle)),
      body: FutureBuilder<List<WorkoutReportSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(strings.fullHistoryLoadError));
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return Center(child: Text(strings.fullHistoryEmpty));
          }

          Future<void> openSession(WorkoutReportSession session) async {
            final destinationFamily = Theme.of(context)
                .extension<AppExpressiveDestinationTokens>()
                ?.family;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  final detail = SessionDetailScreen(
                    WorkoutSession(
                      id: session.id,
                      date: session.date,
                      calendarDayKey: session.calendarDayKey,
                      duration: session.durationSeconds,
                    ),
                  );
                  if (destinationFamily == null) return detail;
                  return AppExpressiveDestinationTheme(
                    family: destinationFamily,
                    child: detail,
                  );
                },
              ),
            );
            if (mounted) _reload();
          }

          if (usesExpressive) {
            return _buildExpressiveHistory(
              context,
              sessions: sessions,
              strings: strings,
              weightUnit: weightUnit,
              onSessionTap: openSession,
            );
          }

          return _buildClassicHistory(
            context,
            sessions: sessions,
            strings: strings,
            onSessionTap: openSession,
          );
        },
      ),
    );
  }

  Widget _buildClassicHistory(
    BuildContext context, {
    required List<WorkoutReportSession> sessions,
    required AppLocalizations strings,
    required Future<void> Function(WorkoutReportSession session) onSessionTap,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final session = sessions[index];
        final date = LocalizedFormatters.date(
          session.calendarDay.toLocalDateTime(),
          Localizations.localeOf(context),
        );
        final duration = formatCompletedWorkoutDuration(
          strings,
          session.durationSeconds,
        );
        return TonosThemeReadyCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              strings.fullHistorySessionSummary(date, duration),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSessionTap(session),
          ),
        );
      },
    );
  }

  Widget _buildExpressiveHistory(
    BuildContext context, {
    required List<WorkoutReportSession> sessions,
    required AppLocalizations strings,
    required WeightUnit weightUnit,
    required Future<void> Function(WorkoutReportSession session) onSessionTap,
  }) {
    final groups = _groupSessionsByDay(sessions);
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final trainTokens = Theme.of(context)
        .extension<AppExpressiveTrainTokens>()!;
    final locale = Localizations.localeOf(context);
    final metadataColor =
        destinationTokens?.onSurfaceSecondary ??
        tonosSecondaryForegroundForSurface(
          context,
          context.surfaceTokens.dashboardSection,
        );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final groupDate = group.first.calendarDay;
        final date = LocalizedFormatters.date(
          groupDate.toLocalDateTime(),
          locale,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: TonosSurface(
                variant: TonosSurfaceVariant.compactCard,
                color:
                    destinationTokens?.surfacePrimary ??
                    trainTokens.actionSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                outlined: false,
                elevation: 0,
                child: Text(
                  date,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color:
                        destinationTokens?.onSurfacePrimary ??
                        trainTokens.actionSecondaryForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            TonosSurface(
              variant: TonosSurfaceVariant.panel,
              color:
                  destinationTokens?.surfaceSecondary ??
                  context.surfaceTokens.dashboardSection,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              outlined: false,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < group.length; index++) ...[
                    _ExpressiveHistorySessionRow(
                      session: group[index],
                      date: date,
                      strings: strings,
                      weightUnit: weightUnit,
                      metadataColor: metadataColor,
                      chevronColor: metadataColor.withValues(alpha: 0.72),
                      onTap: () => onSessionTap(group[index]),
                    ),
                    if (index < group.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: metadataColor.withValues(alpha: 0.16),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpressiveHistorySessionRow extends StatelessWidget {
  const _ExpressiveHistorySessionRow({
    required this.session,
    required this.date,
    required this.strings,
    required this.weightUnit,
    required this.metadataColor,
    required this.chevronColor,
    required this.onTap,
  });

  final WorkoutReportSession session;
  final String date;
  final AppLocalizations strings;
  final WeightUnit weightUnit;
  final Color metadataColor;
  final Color chevronColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final time = LocalizedFormatters.time(session.displayDateTime, locale);
    final duration = formatCompletedWorkoutDuration(
      strings,
      session.durationSeconds,
    );
    final metadata = strings.logbookSessionSummary(
      duration,
      session.exerciseCount,
      session.setCount,
      WeightUnitFormatter.formatVolume(
        session.totalVolume,
        weightUnit,
        locale: locale,
      ),
    );
    final semanticLabel = strings.fullHistorySessionSummary(
      date,
      '$time. $metadata',
    );
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          excludeFromSemantics: true,
          onTap: onTap,
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          softWrap: true,
                          style: textTheme.titleSmall?.copyWith(
                            color: metadataColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metadata,
                          softWrap: true,
                          style: textTheme.bodySmall?.copyWith(
                            color: metadataColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 18, color: chevronColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<List<WorkoutReportSession>> _groupSessionsByDay(
  List<WorkoutReportSession> sessions,
) {
  final groups = <List<WorkoutReportSession>>[];
  for (final session in sessions) {
    if (groups.isEmpty ||
        groups.last.first.calendarDay != session.calendarDay) {
      groups.add([session]);
    } else {
      groups.last.add(session);
    }
  }
  return groups;
}
