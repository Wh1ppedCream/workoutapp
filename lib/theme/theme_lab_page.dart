import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_theme_capabilities.dart';
import 'app_theme_factory.dart';
import 'app_theme_family.dart';
import 'neo_brutalism_pilot_gallery.dart';
import 'theme_extensions.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_media_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_tutorial_tokens.dart';
import 'widgets/tonos_action.dart';
import 'widgets/tonos_field.dart';
import 'widgets/tonos_section.dart';
import 'widgets/tonos_sheet.dart';
import 'widgets/tonos_surface.dart';

/// Development-only gallery for reviewing theme contracts and primitives.
///
/// The page is intentionally guarded here as well as at its route boundary so
/// an accidental release reference cannot expose the gallery.
class ThemeLabPage extends StatefulWidget {
  const ThemeLabPage({super.key});

  @override
  State<ThemeLabPage> createState() => _ThemeLabPageState();
}

class _ThemeLabPageState extends State<ThemeLabPage> {
  late final List<AppThemeFamily> _families;
  AppThemeFamily _family = AppThemeFamily.classic;
  Brightness _brightness = Brightness.dark;
  Locale _locale = const Locale('en');
  double _textScale = 1;
  bool _reducedMotion = false;
  bool _effectsEnabled = true;
  int _previewResetToken = 0;

  @override
  void initState() {
    super.initState();
    _families = AppThemeCapabilities.fromCompileTime().availableFamilies;
    if (!_families.contains(_family)) {
      _family = _families.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Localizations.override(
      context: context,
      locale: _locale,
      child: Builder(
        builder:
            (_) => Theme(
              data: _previewTheme(),
              child: Builder(
                builder:
                    (themeContext) => MediaQuery(
                      data: MediaQuery.of(
                        themeContext,
                      ).copyWith(textScaler: TextScaler.linear(_textScale)),
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('Theme Lab'),
                          actions: [
                            IconButton(
                              tooltip: 'Close Theme Lab',
                              onPressed: () {
                                final navigator = Navigator.of(themeContext);
                                if (navigator.canPop()) {
                                  navigator.maybePop();
                                } else {
                                  navigator.pushReplacementNamed('/main');
                                }
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        body: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          children: [
                            _buildControls(themeContext),
                            const SizedBox(height: 20),
                            if (_family == AppThemeFamily.neoBrutalism) ...[
                              NeoBrutalismPilotGallery(
                                resetToken: _previewResetToken,
                              ),
                              const SizedBox(height: 20),
                            ],
                            _buildSection(
                              themeContext,
                              'Tonos surfaces',
                              _buildSurfaceGallery(),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Tonos sections',
                              _buildSectionGallery(themeContext),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Tonos actions',
                              _buildActionGallery(),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Tonos fields',
                              _buildFieldGallery(),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Tonos sheets',
                              _buildSheetGallery(themeContext),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Material states',
                              _buildMaterialGallery(themeContext),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Typography',
                              _buildTypographyGallery(themeContext),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Data visualization',
                              _buildDataVisualizationGallery(themeContext),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Fitness states',
                              _buildFitnessGallery(),
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              themeContext,
                              'Stress states',
                              _buildStressGallery(),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TonosSurface(
      variant: TonosSurfaceVariant.panel,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Preview controls'),
          Text(strings.appTitle),
          const SizedBox(height: 12),
          DropdownButtonFormField<AppThemeFamily>(
            value: _family,
            decoration: const InputDecoration(labelText: 'Theme family'),
            items: [
              for (final family in _families)
                DropdownMenuItem(
                  value: family,
                  child: Text(_familyLabel(family)),
                ),
            ],
            onChanged: (family) {
              if (family != null) setState(() => _family = family);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Locale>(
            value: _locale,
            decoration: const InputDecoration(labelText: 'Locale'),
            items: [
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem(
                  value: locale,
                  child: Text(_localeLabel(locale)),
                ),
            ],
            onChanged: (locale) {
              if (locale != null) setState(() => _locale = locale);
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<Brightness>(
            segments: const [
              ButtonSegment(
                value: Brightness.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: Brightness.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {_brightness},
            onSelectionChanged: (selection) {
              setState(() => _brightness = selection.first);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Text scale'),
              Text('${_textScale.toStringAsFixed(1)}x'),
            ],
          ),
          Slider(
            value: _textScale,
            min: 1,
            max: 2,
            divisions: 4,
            label: '${_textScale.toStringAsFixed(1)}x',
            onChanged: (value) => setState(() => _textScale = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduced motion'),
            value: _reducedMotion,
            onChanged: (value) => setState(() => _reducedMotion = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Effects enabled'),
            value: _effectsEnabled,
            onChanged: (value) => setState(() => _effectsEnabled = value),
          ),
          const SizedBox(height: 8),
          TonosAction(
            key: const ValueKey('theme-lab-reset'),
            label: 'Reset preview',
            variant: TonosActionVariant.outlined,
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetPreview,
          ),
        ],
      ),
    );
  }

  void _resetPreview() {
    setState(() {
      _family =
          _families.contains(AppThemeFamily.classic)
              ? AppThemeFamily.classic
              : _families.first;
      _brightness = Brightness.dark;
      _locale = const Locale('en');
      _textScale = 1;
      _reducedMotion = false;
      _effectsEnabled = true;
      _previewResetToken++;
    });
  }

  Widget _buildSurfaceGallery() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _surfaceSample('Panel', TonosSurfaceVariant.panel),
        _surfaceSample('Raised panel', TonosSurfaceVariant.panelRaised),
        _surfaceSample('Card', TonosSurfaceVariant.card),
        _surfaceSample('Compact card', TonosSurfaceVariant.compactCard),
        _surfaceSample('Input', TonosSurfaceVariant.input),
        _surfaceSample('Media', TonosSurfaceVariant.media),
        _surfaceSample(
          'Media placeholder',
          TonosSurfaceVariant.mediaPlaceholder,
        ),
      ],
    );
  }

  Widget _surfaceSample(String label, TonosSurfaceVariant variant) {
    return SizedBox(
      width: 160,
      child: TonosSurface(
        variant: variant,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_surfaceIcon(variant)),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGallery() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const TonosAction(label: 'Primary', onPressed: _noop),
        const TonosAction(
          label: 'Tonal',
          variant: TonosActionVariant.tonal,
          onPressed: _noop,
        ),
        const TonosAction(
          label: 'Outlined',
          variant: TonosActionVariant.outlined,
          onPressed: _noop,
        ),
        const TonosAction(
          label: 'Destructive',
          variant: TonosActionVariant.destructive,
          onPressed: _noop,
        ),
        const TonosAction(
          label: 'Text',
          variant: TonosActionVariant.text,
          onPressed: _noop,
        ),
        const TonosAction(label: 'Disabled', onPressed: null),
      ],
    );
  }

  Widget _buildSectionGallery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosSection(
          title: 'Workout summary',
          subtitle: 'A representative feature section',
          leading: const Icon(Icons.fitness_center_outlined),
          child: Text(
            'Three sets completed',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 12),
        TonosSection(
          title: 'Selected plan',
          variant: TonosSectionVariant.panelRaised,
          leading: const Icon(Icons.assignment_outlined),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Full Body'),
            subtitle: Text('A parent-derived standard list tile'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldGallery() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosField(
          labelText: 'Exercise name',
          hintText: 'Barbell squat',
          semanticLabel: 'Exercise name field',
        ),
        SizedBox(height: 12),
        TonosField(
          variant: TonosFieldVariant.search,
          labelText: 'Search exercises',
          hintText: 'Try overhead press',
        ),
        SizedBox(height: 12),
        TonosField(
          labelText: 'Offline note',
          errorText: 'Example error state',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildSheetGallery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosSheet(
          title: 'Workout details',
          closeTooltip: 'Close workout details',
          onClose: _noop,
          child: const Text(
            'A sheet recipe with a handle, title, close action, and themed content.',
          ),
        ),
        const SizedBox(height: 12),
        TonosSheet(
          showHandle: false,
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Handle-free content remains available for compact sheets.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialGallery(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TonosSurface(
      variant: TonosSurfaceVariant.panelRaised,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.view_agenda_outlined),
              title: Text('Standard Material card'),
              subtitle: Text('Inherited card and list-tile recipes'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('theme-lab-material-field'),
            decoration: InputDecoration(
              labelText: strings.appTitle,
              hintText: 'Example workout',
              errorText: 'Example validation state',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const ValueKey('theme-lab-material-dropdown'),
            value: 'Workout',
            decoration: const InputDecoration(labelText: 'Dropdown'),
            items: const [
              DropdownMenuItem(value: 'Workout', child: Text('Workout')),
              DropdownMenuItem(value: 'Plan', child: Text('Plan')),
            ],
            onChanged: _noopNullableString,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active plan'),
            value: true,
            onChanged: _noopBool,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Completed set'),
            value: true,
            onChanged: _noopNullableBool,
          ),
          RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            title: const Text('Selected option'),
            value: 1,
            groupValue: 1,
            onChanged: _noopNullableInt,
          ),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text('Selected')),
              ChoiceChip(label: Text('Choice'), selected: true),
              CircularProgressIndicator(),
              SizedBox(width: 120, child: LinearProgressIndicator(value: 0.62)),
            ],
          ),
          const SizedBox(height: 12),
          BottomNavigationBar(
            currentIndex: 0,
            onTap: _noopInt,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Train',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                label: 'Progress',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyGallery(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TonosSurface(
      variant: TonosSurfaceVariant.panel,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Headline role', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Title role', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Body role with a longer line for wrapping review.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text('Label role', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Large numeric value: 1,234,567 lbs',
            style: textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDataVisualizationGallery(BuildContext context) {
    final data = context.dataVisualizationTokens;
    return TonosSurface(
      variant: TonosSurfaceVariant.panelRaised,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Series and state roles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _dataSwatch('Primary', data.primarySeries),
              _dataSwatch('Secondary', data.secondarySeries),
              _dataSwatch('Positive', data.positive),
              _dataSwatch('Negative', data.negative),
              _dataSwatch('Selection', data.selection),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.72,
            color: data.primarySeries,
            backgroundColor: data.grid,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Today', style: TextStyle(color: data.label)),
              ),
              Text('72%', style: TextStyle(color: data.selection)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataSwatch(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _buildFitnessGallery() {
    return TonosSection(
      title: 'Workout session',
      subtitle: 'Representative fitness states without persisted data',
      leading: const Icon(Icons.fitness_center),
      variant: TonosSectionVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _setRow('Set 1', completed: true),
          _setRow('Set 2', completed: false),
          _setRow('Set 3', completed: false),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TonosAction(
                label: 'Add set',
                variant: TonosActionVariant.text,
                icon: const Icon(Icons.add),
                onPressed: _noop,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TonosAction(
            label: 'Finish workout',
            expand: true,
            onPressed: _noop,
          ),
          const SizedBox(height: 8),
          const TonosAction(
            label: 'Discard workout',
            variant: TonosActionVariant.destructive,
            expand: true,
            onPressed: _noop,
          ),
        ],
      ),
    );
  }

  Widget _setRow(String label, {required bool completed}) {
    return Row(
      children: [
        Checkbox(value: completed, onChanged: _noopNullableBool),
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        const SizedBox(
          width: 74,
          child: TextField(
            decoration: InputDecoration(labelText: 'Weight'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(
          width: 60,
          child: TextField(
            decoration: InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildStressGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosSurface(
          variant: TonosSurfaceVariant.mediaPlaceholder,
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(Icons.image_not_supported_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Missing media placeholder with a long localized description.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TonosSurface(
          variant: TonosSurfaceVariant.panelRaised,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_off_outlined),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Offline state')),
                  Chip(
                    avatar: const Icon(Icons.sync_problem_outlined),
                    label: const Text('Retry later'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Loading large values: 1,234,567 lbs / 987,654 sets'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Text('Disabled action after an error')),
                  const TonosAction(label: 'Unavailable', onPressed: null),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget child) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  ThemeData _previewTheme() {
    final base =
        _brightness == Brightness.light
            ? AppThemeFactory.light(_family)
            : AppThemeFactory.dark(_family);
    final extensions = [
      for (final extension in base.extensions.values)
        if (extension is AppMotionTokens && _reducedMotion)
          extension.copyWith(
            instant: extension.reduced,
            standard: extension.reduced,
            emphasized: extension.reduced,
            page: extension.reduced,
            quick: extension.reduced,
            pageTransition: extension.reduced,
            exerciseDetailSelection: extension.reduced,
            reduced: extension.reduced,
            standardCurve: extension.reducedCurve,
            emphasizedCurve: extension.reducedCurve,
            reducedCurve: extension.reducedCurve,
          )
        else if (extension is AppTutorialTokens)
          extension.copyWith(
            pageDuration:
                _reducedMotion ? Duration.zero : extension.pageDuration,
            selectionDuration:
                _reducedMotion ? Duration.zero : extension.selectionDuration,
            guidedScrollDuration:
                _reducedMotion ? Duration.zero : extension.guidedScrollDuration,
            coachDuration:
                _reducedMotion ? Duration.zero : extension.coachDuration,
            cardShadow:
                _effectsEnabled
                    ? extension.cardShadow
                    : const BoxShadow(color: Colors.transparent),
            coachShadow:
                _effectsEnabled
                    ? extension.coachShadow
                    : const BoxShadow(color: Colors.transparent),
            effectsEnabled: _effectsEnabled,
          )
        else if (extension is AppEffectTokens && !_effectsEnabled)
          extension.copyWith(
            cardElevation: 0,
            dialogElevation: 0,
            sheetElevation: 0,
            exerciseDetailSheetElevation: 0,
            swapSheetElevation: 0,
            progressRemoveBadgeShadow: const BoxShadow(
              color: Colors.transparent,
            ),
            feedbackElevation: 0,
            cardShadow: extension.cardShadow.withValues(
              alpha: extension.noEffectsShadowOpacity,
            ),
            cardShadowBlur: extension.noEffectsShadowBlur,
            cardShadowOffset: Offset.zero,
            raisedPanelShadowOffset: Offset.zero,
            primaryActionShadowOffset: Offset.zero,
            dialogShadowOffset: Offset.zero,
            shadowColor: extension.shadowColor.withValues(
              alpha: extension.noEffectsShadowOpacity,
            ),
            shadowOpacity: extension.noEffectsShadowOpacity,
            shadowBlur: extension.noEffectsShadowBlur,
            backdropBlurSigma: extension.noEffectsBackdropBlurSigma,
          )
        else if (extension is AppMediaTokens && !_effectsEnabled)
          extension.copyWith(overlayShadow: const [])
        else
          extension,
    ];
    var preview = base.copyWith(extensions: extensions);
    if (!_effectsEnabled) {
      final effects = preview.effectTokens;
      final tooltipDecoration = preview.tooltipTheme.decoration;
      preview = preview.copyWith(
        bottomSheetTheme: preview.bottomSheetTheme.copyWith(
          elevation: effects.sheetElevation,
          modalElevation: effects.sheetElevation,
        ),
        dialogTheme: preview.dialogTheme.copyWith(
          elevation: effects.dialogElevation,
        ),
        tooltipTheme: preview.tooltipTheme.copyWith(
          decoration:
              tooltipDecoration is BoxDecoration
                  ? tooltipDecoration.copyWith(boxShadow: const [])
                  : tooltipDecoration,
        ),
      );
    }
    return preview;
  }
}

String _familyLabel(AppThemeFamily family) => switch (family) {
  AppThemeFamily.classic => 'Classic',
  AppThemeFamily.neoBrutalism => 'Neo-Brutalism',
};

String _localeLabel(Locale locale) => locale.toLanguageTag();

IconData _surfaceIcon(TonosSurfaceVariant variant) => switch (variant) {
  TonosSurfaceVariant.panel => Icons.view_agenda_outlined,
  TonosSurfaceVariant.panelRaised => Icons.layers_outlined,
  TonosSurfaceVariant.card => Icons.crop_square,
  TonosSurfaceVariant.compactCard => Icons.dashboard_outlined,
  TonosSurfaceVariant.input => Icons.edit_outlined,
  TonosSurfaceVariant.media => Icons.image_outlined,
  TonosSurfaceVariant.mediaPlaceholder => Icons.image_not_supported_outlined,
};

void _noop() {}

void _noopBool(bool _) {}

void _noopNullableBool(bool? _) {}

void _noopNullableInt(int? _) {}

void _noopNullableString(String? _) {}

void _noopInt(int _) {}
