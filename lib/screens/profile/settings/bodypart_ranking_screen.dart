// File: lib/screens/profile/settings/bodypart_ranking_screen.dart

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/safe_failure_localizations.dart';
import '../../../models/models.dart';
import '../../../repositories/app_repository.dart';
import '../../../services/safe_failure.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../widgets/safe_error_view.dart';
import 'analytics_destination_surfaces.dart';

class BodyPartRankingScreen extends StatefulWidget {
  const BodyPartRankingScreen({super.key});

  @override
  State<BodyPartRankingScreen> createState() => _BodyPartRankingScreenState();
}

class _BodyPartRankingScreenState extends State<BodyPartRankingScreen> {
  AppRepository get _repo => context.read<AppRepository>();
  List<BodyPart> _parts = [];
  Map<int, int> _ranks = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  SafeFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _failure = null;
      });
    }
    try {
      final parts = await _repo.fetchAllBodyPartsFull();
      final rows = await _repo.getAllBodyPartRanks();
      if (!mounted) return;
      setState(() {
        _parts = parts;
        _ranks = {for (var r in rows) r.bodyPartId: r.rank};
        _sortByRank();
        _isLoading = false;
        _dirty = false;
        _failure = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = SafeFailure.classify(e);
        _isLoading = false;
      });
    }
  }

  void _sortByRank() {
    _parts.sort((a, b) => (_ranks[a.id] ?? 0).compareTo(_ranks[b.id] ?? 0));
  }

  void _applyRankOrder() {
    for (var i = 0; i < _parts.length; i++) {
      _ranks[_parts[i].id] = i + 1;
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final part = _parts.removeAt(oldIndex);
      _parts.insert(newIndex, part);
      _applyRankOrder();
      _dirty = true;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      for (var entry in _ranks.entries) {
        await _repo.setBodyPartRank(entry.key, entry.value);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .rankingsSaved(AppLocalizations.of(context).anatomyBodyParts),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).rankingsSaveError(
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
    final destination = analyticsDestinationTokens(context);

    return AppExpressiveDestinationTheme(
      family: AppExpressiveDestinationFamily.analytics,
      child: Scaffold(
        backgroundColor: destination?.pageCanvas,
        appBar: destination == null
            ? AppBar(
                title: Text(strings.rankingsTitle(strings.anatomyBodyParts)),
                scrolledUnderElevation: 0,
              )
            : null,
        bottomNavigationBar: _dirty
            ? SettingsSaveBar(
                label: _isSaving
                    ? strings.nutritionSaving
                    : strings.rankingsSave,
                onPressed: _isSaving ? null : _saveAll,
                saveIcon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                decorated: false,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              )
            : null,
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context);
    final isExpressive = analyticsDestinationTokens(context) != null;
    if (_isLoading) {
      return _withExpressiveBackButton(
        context,
        isExpressive: isExpressive,
        content: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_failure != null) {
      return _withExpressiveBackButton(
        context,
        isExpressive: isExpressive,
        content: SafeErrorView(
          title: strings.safeFailureLoadTitle,
          failure: _failure!,
          onRetry: _load,
        ),
      );
    }
    if (_parts.isEmpty) {
      return _withExpressiveBackButton(
        context,
        isExpressive: isExpressive,
        content: Center(child: Text(strings.rankingsNoBodyParts)),
      );
    }

    if (!isExpressive) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: SettingsHeroCard(
              title: strings.rankingsTitle(strings.anatomyBodyParts),
              subtitle: strings.rankingsHero(
                strings.anatomyBodyParts.toLowerCase(),
              ),
              icon: Icons.accessibility_new,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _parts.length,
              onReorder: _onReorder,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemBuilder: (context, index) {
                final part = _parts[index];
                final rank = _ranks[part.id] ?? index + 1;
                return SettingsRankingTile(
                  key: ValueKey(part.id),
                  index: index,
                  name: Text(
                    part.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: settingsRankingNameTextStyle(context),
                  ),
                  rank: rank,
                  icon: Icons.accessibility_new,
                  rankLabel: strings.rankingsRank,
                  onRankSubmitted: (value) {
                    setState(() {
                      _ranks[part.id] = int.tryParse(value) ?? rank;
                      _sortByRank();
                      _dirty = true;
                    });
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    final destination = analyticsDestinationTokens(context)!;
    return ReorderableListView.builder(
      itemCount: _parts.length,
      onReorder: _onReorder,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _expressiveBackButton(context),
          const SizedBox(height: 4),
          AnalyticsRouteHeader(
            title: strings.settingsBodyPartRankings,
            subtitle: strings.rankingsHero(
              strings.volumeBodyParts.toLowerCase(),
            ),
            icon: Icons.accessibility_new,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 2),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                strings.rankingsRank,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: destination.supportingForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (context, index) {
        return _buildExpressiveRow(context, index, strings);
      },
    );
  }

  Widget _buildExpressiveRow(
    BuildContext context,
    int index,
    AppLocalizations strings,
  ) {
    final part = _parts[index];
    final rank = _ranks[part.id] ?? index + 1;
    return _ExpressiveBodyPartRankingRow(
      key: ValueKey(part.id),
      index: index,
      partName: part.name,
      name: Text(
        part.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: settingsRankingNameTextStyle(context),
      ),
      rank: rank,
      rankLabel: strings.rankingsRank,
      onRankSubmitted: (value) {
        setState(() {
          _ranks[part.id] = int.tryParse(value) ?? rank;
          _sortByRank();
          _dirty = true;
        });
      },
    );
  }

  Widget _withExpressiveBackButton(
    BuildContext context, {
    required bool isExpressive,
    required Widget content,
  }) {
    if (!isExpressive) return content;
    return Column(
      children: [
        _expressiveBackButton(context),
        Expanded(child: content),
      ],
    );
  }

  Widget _expressiveBackButton(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: IconButton(
      tooltip: AppLocalizations.of(context).commonBack,
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back),
    ),
  );
}

class _ExpressiveBodyPartRankingRow extends StatefulWidget {
  const _ExpressiveBodyPartRankingRow({
    super.key,
    required this.index,
    required this.partName,
    required this.name,
    required this.rank,
    required this.rankLabel,
    required this.onRankSubmitted,
  });

  final int index;
  final String partName;
  final Widget name;
  final int rank;
  final String rankLabel;
  final ValueChanged<String> onRankSubmitted;

  @override
  State<_ExpressiveBodyPartRankingRow> createState() =>
      _ExpressiveBodyPartRankingRowState();
}

class _ExpressiveBodyPartRankingRowState
    extends State<_ExpressiveBodyPartRankingRow> {
  late final TextEditingController _rankController;
  late final FocusNode _rankFocusNode;

  @override
  void initState() {
    super.initState();
    _rankController = TextEditingController(text: widget.rank.toString());
    _rankFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ExpressiveBodyPartRankingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rank != widget.rank) {
      _rankController.value = TextEditingValue(
        text: widget.rank.toString(),
        selection: TextSelection.collapsed(
          offset: widget.rank.toString().length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _rankController.dispose();
    _rankFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = analyticsDestinationTokens(context);
    if (tokens == null) {
      return SettingsRankingTile(
        index: widget.index,
        name: widget.name,
        rank: widget.rank,
        icon: Icons.accessibility_new,
        rankLabel: widget.rankLabel,
        onRankSubmitted: widget.onRankSubmitted,
      );
    }

    final role = switch (widget.index % 3) {
      0 => AnalyticsSurfaceRole.secondary,
      1 => AnalyticsSurfaceRole.tertiary,
      _ => AnalyticsSurfaceRole.accent,
    };
    final foreground = analyticsForegroundColor(tokens, role);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactLayout =
        MediaQuery.sizeOf(context).width <= 360 || textScale > 1.15;
    final rankFieldWidth = textScale <= 1.15
        ? 80.0
        : (80 * (textScale / 1.15)).clamp(80.0, 108.0).toDouble();
    final semanticFieldLabel =
        '${widget.partName}, ${widget.rankLabel} ${widget.rank}';
    final rankField = SizedBox(
      width: rankFieldWidth,
      height: 52,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _rankController,
        builder: (context, value, field) => Semantics(
          container: true,
          excludeSemantics: true,
          label: semanticFieldLabel,
          value: value.text,
          textField: true,
          focusable: true,
          onTap: _rankFocusNode.requestFocus,
          onFocus: _rankFocusNode.requestFocus,
          onSetText: (text) {
            _rankController.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
            widget.onRankSubmitted(text);
          },
          child: field!,
        ),
        child: AnimatedBuilder(
          animation: _rankFocusNode,
          builder: (context, _) {
            final isFocused = _rankFocusNode.hasFocus;
            return DecoratedBox(
              key: ValueKey('rank-painted-box-${widget.rank}'),
              decoration: BoxDecoration(
                color: tokens.pageCanvas.withValues(alpha: 0.58),
                border: Border.all(
                  color: isFocused
                      ? tokens.outlineAccent
                      : tokens.outlineAccent.withValues(alpha: 0.6),
                  width: isFocused ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextFormField(
                  key: ValueKey('rank-${widget.rank}'),
                  controller: _rankController,
                  focusNode: _rankFocusNode,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onFieldSubmitted: widget.onRankSubmitted,
                ),
              ),
            );
          },
        ),
      ),
    );

    final leadingContent = Row(
      children: [
        ReorderableDragStartListener(
          index: widget.index,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(Icons.drag_indicator, color: foreground, size: 21),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tokens.surfacePrimary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.accessibility_new,
            color: tokens.onSurfacePrimary,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground),
              child: widget.name,
            ),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (MediaQuery.sizeOf(context).width - 32)
                  .clamp(0.0, double.infinity)
                  .toDouble();
        return SizedBox(
          width: rowWidth,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 2, 10, 2),
            decoration: BoxDecoration(
              color: analyticsSurfaceColor(tokens, role),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomRight: const Radius.circular(22),
                bottomLeft: Radius.circular(widget.index.isEven ? 8 : 22),
              ),
            ),
            child: compactLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leadingContent,
                      const SizedBox(height: 4),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: rankField,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: leadingContent),
                      const SizedBox(width: 8),
                      rankField,
                    ],
                  ),
          ),
        );
      },
    );
  }
}
