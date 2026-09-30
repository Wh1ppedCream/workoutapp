import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_theme_factory.dart';
import 'app_theme_family.dart';
import 'expressive_theme.dart';
import 'theme_extensions.dart';
import 'tokens/app_effect_tokens.dart';
import 'tokens/app_media_tokens.dart';

enum TonosPreviewLook { expressive, classic }

/// In-memory presentation settings for the isolated Expressive review app.
///
/// This controller never reads or writes `ThemeProvider` or app preferences.
/// It switches only the rendered theme and review-local accessibility settings.
class TonosPreviewPresentation extends ChangeNotifier {
  TonosPreviewPresentation({this.fixtureReset, this.missingProfileFixture});

  static final ThemeData _classicLight = AppThemeFactory.light(
    AppThemeFamily.classic,
  );
  static final ThemeData _classicDark = AppThemeFactory.dark(
    AppThemeFamily.classic,
  );
  static final Expando<ThemeData> _effectsOffThemeCache = Expando<ThemeData>(
    'Tonos preview no-effects themes',
  );

  static const Locale _appLocale = Locale('und');

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Future<void> Function(NavigatorState navigator)? fixtureReset;
  final Future<void> Function(NavigatorState navigator)? missingProfileFixture;
  late final NavigatorObserver navigatorObserver =
      _TonosPreviewNavigatorObserver(_onRouteStackChanged);
  int _routeDepth = 0;
  TonosPreviewLook _look = TonosPreviewLook.expressive;
  ExpressivePaletteTreatment _paletteTreatment =
      ExpressivePaletteTreatment.curated;
  Brightness _brightness = Brightness.light;
  bool _reducedMotion = false;
  bool _effectsOff = false;
  bool _controlsDialogOpen = false;
  bool _fixtureResetInProgress = false;
  Locale? _localeOverride;
  double? _textScaleOverride;

  TonosPreviewLook get look => _look;
  ExpressivePaletteTreatment get paletteTreatment => _paletteTreatment;
  Brightness get brightness => _brightness;
  ThemeMode get themeMode =>
      _brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  bool get reducedMotion => _reducedMotion;
  bool get effectsOff => _effectsOff;
  bool get controlsDialogOpen => _controlsDialogOpen;
  bool get fixtureResetInProgress => _fixtureResetInProgress;
  Locale? get localeOverride => _localeOverride;
  double? get textScaleOverride => _textScaleOverride;
  bool get canResetFixtures => fixtureReset != null;
  bool get canShowMissingProfileFixture => missingProfileFixture != null;
  bool get controlsChromeEnabled => const bool.fromEnvironment(
    'TONOS_PREVIEW_SHOW_CONTROLS',
    defaultValue: true,
  );
  bool get _hasChildRoute => _routeDepth > 1;
  bool get showControlEntry =>
      controlsChromeEnabled && !_hasChildRoute && !_controlsDialogOpen;

  ThemeData get lightTheme => switch (_look) {
    TonosPreviewLook.expressive => ExpressiveThemeDefinition.light(
      treatment: _paletteTreatment,
    ),
    TonosPreviewLook.classic => _classicLight,
  };

  ThemeData get darkTheme => switch (_look) {
    TonosPreviewLook.expressive => ExpressiveThemeDefinition.dark(
      treatment: _paletteTreatment,
    ),
    TonosPreviewLook.classic => _classicDark,
  };

  ThemeData get activeTheme {
    final selected = _brightness == Brightness.dark ? darkTheme : lightTheme;
    if (!_effectsOff) return selected;
    final cached = _effectsOffThemeCache[selected];
    if (cached != null) return cached;
    final noEffects = _themeWithoutEffects(selected);
    _effectsOffThemeCache[selected] = noEffects;
    return noEffects;
  }

  void setLook(TonosPreviewLook value) {
    if (_look == value) return;
    _look = value;
    notifyListeners();
  }

  void setPaletteTreatment(ExpressivePaletteTreatment value) {
    if (_paletteTreatment == value) return;
    _paletteTreatment = value;
    notifyListeners();
  }

  void setBrightness(Brightness value) {
    if (_brightness == value) return;
    _brightness = value;
    notifyListeners();
  }

  void setReducedMotion(bool value) {
    if (_reducedMotion == value) return;
    _reducedMotion = value;
    notifyListeners();
  }

  void setEffectsOff(bool value) {
    if (_effectsOff == value) return;
    _effectsOff = value;
    notifyListeners();
  }

  void setLocaleOverride(Locale? value) {
    if (_localeOverride == value) return;
    _localeOverride = value;
    notifyListeners();
  }

  void setTextScaleOverride(double? value) {
    if (_textScaleOverride == value) return;
    _textScaleOverride = value;
    notifyListeners();
  }

  /// Restores review-only choices without touching persisted preferences.
  void resetReviewSettings() {
    _look = TonosPreviewLook.expressive;
    _paletteTreatment = ExpressivePaletteTreatment.curated;
    _brightness = Brightness.light;
    _reducedMotion = false;
    _effectsOff = false;
    _localeOverride = null;
    _textScaleOverride = null;
    notifyListeners();
  }

  Future<void> resetFixtures() async {
    final reset = fixtureReset;
    final navigator = navigatorKey.currentState;
    if (reset == null || navigator == null || _fixtureResetInProgress) return;
    _fixtureResetInProgress = true;
    notifyListeners();
    try {
      await reset(navigator);
    } finally {
      _fixtureResetInProgress = false;
      notifyListeners();
    }
  }

  Future<void> showMissingProfileFixture() async {
    final showFixture = missingProfileFixture;
    final navigator = navigatorKey.currentState;
    if (showFixture == null || navigator == null) return;
    await showFixture(navigator);
  }

  static ThemeData _themeWithoutEffects(ThemeData base) {
    final effects = base.effectTokens;
    final noEffects = effects.copyWith(
      cardElevation: 0,
      dialogElevation: 0,
      sheetElevation: 0,
      exerciseDetailSheetElevation: 0,
      swapSheetElevation: 0,
      progressRemoveBadgeShadow: const BoxShadow(color: Colors.transparent),
      feedbackElevation: 0,
      cardShadow: effects.cardShadow.withValues(
        alpha: effects.noEffectsShadowOpacity,
      ),
      cardShadowBlur: effects.noEffectsShadowBlur,
      cardShadowOffset: Offset.zero,
      completedSetShadowOffset: Offset.zero,
      raisedPanelShadowOffset: Offset.zero,
      primaryActionShadowOffset: Offset.zero,
      dialogShadowOffset: Offset.zero,
      shadowColor: effects.shadowColor.withValues(
        alpha: effects.noEffectsShadowOpacity,
      ),
      shadowOpacity: effects.noEffectsShadowOpacity,
      shadowBlur: effects.noEffectsShadowBlur,
      backdropBlurSigma: effects.noEffectsBackdropBlurSigma,
    );
    final List<ThemeExtension<dynamic>> extensions = base.extensions.values
        .map<ThemeExtension<dynamic>>((extension) {
          if (extension is AppEffectTokens) return noEffects;
          if (extension is AppMediaTokens) {
            return extension.copyWith(overlayShadow: const <BoxShadow>[]);
          }
          return extension;
        })
        .toList(growable: false);
    final tooltipDecoration = base.tooltipTheme.decoration;
    return base.copyWith(
      extensions: extensions,
      cardTheme: base.cardTheme.copyWith(elevation: noEffects.cardElevation),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        elevation: noEffects.sheetElevation,
        modalElevation: noEffects.sheetElevation,
      ),
      dialogTheme: base.dialogTheme.copyWith(
        elevation: noEffects.dialogElevation,
      ),
      tooltipTheme: base.tooltipTheme.copyWith(
        decoration: tooltipDecoration is BoxDecoration
            ? tooltipDecoration.copyWith(boxShadow: const <BoxShadow>[])
            : tooltipDecoration,
      ),
    );
  }

  Future<void> openControls() async {
    final dialogContext = navigatorKey.currentState?.overlay?.context;
    if (dialogContext == null || _controlsDialogOpen) return;
    _controlsDialogOpen = true;
    notifyListeners();
    try {
      await showDialog<void>(
        context: dialogContext,
        builder: (_) => _TonosPreviewSettingsDialog(presentation: this),
      );
    } finally {
      _controlsDialogOpen = false;
      notifyListeners();
    }
  }

  void _onRouteStackChanged(int depth) {
    final wasOnChildRoute = _hasChildRoute;
    _routeDepth = depth;
    if (wasOnChildRoute != _hasChildRoute) notifyListeners();
  }
}

class _TonosPreviewNavigatorObserver extends NavigatorObserver {
  _TonosPreviewNavigatorObserver(this.onStackChanged);

  final void Function(int depth) onStackChanged;
  final List<Route<dynamic>> _routes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _routes.add(route);
    onStackChanged(_routes.length);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routes.remove(route);
    onStackChanged(_routes.length);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _routes.remove(route);
    onStackChanged(_routes.length);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final oldIndex = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (oldIndex >= 0 && newRoute != null) {
      _routes[oldIndex] = newRoute;
    }
    onStackChanged(_routes.length);
  }
}

/// A preview-only top strip that reserves space for review controls.
///
/// Keeping the strip outside the Navigator gives the entry a stable position
/// without covering the app bar or any of the app's own controls.
class TonosPreviewControls extends StatefulWidget {
  const TonosPreviewControls({super.key, required this.presentation});

  final TonosPreviewPresentation presentation;

  @override
  State<TonosPreviewControls> createState() => _TonosPreviewControlsState();
}

class _TonosPreviewControlsState extends State<TonosPreviewControls> {
  static const double _stripHeight = 52;

  late final FocusNode _entryFocusNode = FocusNode(
    debugLabel: 'Expressive preview controls',
  );

  @override
  void dispose() {
    _entryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openControls() async {
    final shouldRestoreFocus = _entryFocusNode.hasFocus;
    await widget.presentation.openControls();
    if (!shouldRestoreFocus || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.presentation.showControlEntry) {
        _entryFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentation = widget.presentation;
    if (!presentation.controlsChromeEnabled) {
      return const SizedBox.shrink();
    }

    final topInset = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        width: double.infinity,
        height: topInset + _stripHeight,
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: SizedBox(
            height: _stripHeight,
            child: Align(
              alignment: Alignment.centerRight,
              child: presentation.showControlEntry
                  ? Semantics(
                      label: 'Open preview controls',
                      button: true,
                      onTap: _openControls,
                      child: ExcludeSemantics(
                        child: IconButton.filledTonal(
                          focusNode: _entryFocusNode,
                          onPressed: _openControls,
                          icon: const Icon(Icons.tune),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TonosPreviewSettingsDialog extends StatelessWidget {
  const _TonosPreviewSettingsDialog({required this.presentation});

  final TonosPreviewPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: presentation,
      builder: (context, _) => _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {
    final selectedScale = presentation.textScaleOverride ?? 0;
    final selectedLocale =
        presentation.localeOverride ?? TonosPreviewPresentation._appLocale;
    final locales = <Locale>[
      TonosPreviewPresentation._appLocale,
      ...AppLocalizations.supportedLocales,
    ];

    return AlertDialog(
      title: const Text('Preview controls'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Rendered recipe'),
            const SizedBox(height: 8),
            SegmentedButton<TonosPreviewLook>(
              segments: const [
                ButtonSegment(
                  value: TonosPreviewLook.expressive,
                  label: Text('Expressive'),
                ),
                ButtonSegment(
                  value: TonosPreviewLook.classic,
                  label: Text('Classic'),
                ),
              ],
              selected: <TonosPreviewLook>{presentation.look},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) presentation.setLook(selected.first);
              },
            ),
            if (presentation.look == TonosPreviewLook.expressive) ...[
              const SizedBox(height: 12),
              const Text('Palette treatment'),
              const SizedBox(height: 8),
              SegmentedButton<ExpressivePaletteTreatment>(
                segments: const [
                  ButtonSegment(
                    value: ExpressivePaletteTreatment.generated,
                    label: Text('Generated'),
                  ),
                  ButtonSegment(
                    value: ExpressivePaletteTreatment.curated,
                    label: Text('Curated'),
                  ),
                ],
                selected: <ExpressivePaletteTreatment>{
                  presentation.paletteTreatment,
                },
                onSelectionChanged: (selected) {
                  if (selected.isNotEmpty) {
                    presentation.setPaletteTreatment(selected.first);
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
            const Text('Brightness'),
            const SizedBox(height: 8),
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
              selected: <Brightness>{presentation.brightness},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  presentation.setBrightness(selected.first);
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduced motion'),
              value: presentation.reducedMotion,
              onChanged: presentation.setReducedMotion,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Effects off'),
              subtitle: const Text('Also stops optional spring recovery'),
              value: presentation.effectsOff,
              onChanged: presentation.setEffectsOff,
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Locale'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  isExpanded: true,
                  value: selectedLocale,
                  items: [
                    for (final locale in locales)
                      DropdownMenuItem(
                        value: locale,
                        child: Text(
                          locale == TonosPreviewPresentation._appLocale
                              ? 'App/device default'
                              : locale.toLanguageTag(),
                        ),
                      ),
                  ],
                  onChanged: (locale) => presentation.setLocaleOverride(
                    locale == TonosPreviewPresentation._appLocale
                        ? null
                        : locale,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Text scale'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  isExpanded: true,
                  value: selectedScale,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('OS/app default')),
                    DropdownMenuItem(value: 1, child: Text('1×')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5×')),
                    DropdownMenuItem(value: 2, child: Text('2×')),
                  ],
                  onChanged: (scale) => presentation.setTextScaleOverride(
                    scale == null || scale == 0 ? null : scale,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: presentation.resetReviewSettings,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset review controls'),
            ),
            if (presentation.canResetFixtures) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: presentation.fixtureResetInProgress
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        await presentation.resetFixtures();
                      },
                icon: const Icon(Icons.restore),
                label: const Text('Reset sandbox fixtures'),
              ),
            ],
            if (presentation.canShowMissingProfileFixture) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await presentation.showMissingProfileFixture();
                },
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('Show missing-profile state'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
