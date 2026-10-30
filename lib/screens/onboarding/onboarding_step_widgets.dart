part of '../onboarding_flow.dart';

class _OnboardingHeader extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final String skipLabel;

  const _OnboardingHeader({
    required this.currentPage,
    required this.pageCount,
    required this.title,
    required this.onBack,
    required this.onSkip,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);
    final neo = context.usesNeoPresentation;
    final expressiveTokens = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final progressSurface =
        expressiveTokens?.equipmentSurface ??
        (neo ? surfaces.settingsSection : scheme.surfaceContainerHighest);
    final progressValue =
        expressiveTokens?.actionPrimary ??
        (neo ? surfaces.settingsHero : scheme.primary);
    final progressSecondary =
        expressiveTokens?.onPage ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, progressSurface)
            : scheme.onSurfaceVariant);
    final progress = pageCount <= 1 ? 1.0 : (currentPage + 1) / pageCount;
    final usesLocalizedLayout =
        expressiveTokens != null ||
        Localizations.localeOf(context).languageCode != 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        usesLocalizedLayout
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: expressiveTokens == null ? 104 : 72,
                    child: onBack == null
                        ? null
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: onBack,
                              tooltip: strings.onboardingPreviousStepTooltip,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.chevron_left, size: 26),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: expressiveTokens == null ? 104 : 72,
                    child: onSkip == null
                        ? null
                        : TextButton(
                            onPressed: onSkip,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(skipLabel, maxLines: 1),
                            ),
                          ),
                  ),
                ],
              )
            : SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 72,
                        child: onBack == null
                            ? null
                            : IconButton(
                                onPressed: onBack,
                                tooltip: strings.onboardingPreviousStepTooltip,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.chevron_left, size: 26),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 76),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (onSkip != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 72,
                          child: TextButton(
                            onPressed: onSkip,
                            child: Text(skipLabel),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: context.tutorialTokens.pillShape,
          child: TonosExpressiveAnimatedValue(
            value: progress,
            duration: TonosExpressiveStateMotion.standard,
            builder: (context, animatedProgress) => LinearProgressIndicator(
              value: animatedProgress,
              // Progress-bar roles require a numeric value; step copy is its label.
              semanticsLabel: strings.onboardingStepProgress(
                currentPage + 1,
                pageCount,
              ),
              semanticsValue: '${(progress * 100).round()}%',
              minHeight: 8,
              backgroundColor: progressSurface,
              valueColor: neo || expressiveTokens != null
                  ? AlwaysStoppedAnimation<Color>(progressValue)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.onboardingStepProgress(currentPage + 1, pageCount),
          style: theme.textTheme.bodySmall?.copyWith(color: progressSecondary),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionHint;
  final List<Widget> children;

  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionHint,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressiveTokens = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final cardSurface =
        expressiveTokens?.planSupportSurface ??
        (neo
            ? surfaces.settingsSection
            : scheme.surfaceContainerHighest.withValues(alpha: 0.34));
    final cardForeground =
        expressiveTokens?.planSupportForeground ??
        (neo
            ? tonosForegroundForSurface(context, cardSurface)
            : scheme.onSurface);
    final cardSecondary =
        expressiveTokens?.planSupportForeground ??
        (neo
            ? tonosSecondaryForegroundForSurface(context, cardSurface)
            : scheme.onSurfaceVariant);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: expressiveTokens == null ? 0 : 88),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: expressiveTokens != null
              ? expressiveTokens.supportShape
              : neo
              ? shapes.settingsPanel
              : context.tutorialTokens.heroShape,
          border: Border.all(
            color:
                expressiveTokens?.outline.withValues(alpha: 0.35) ??
                (neo
                    ? tonosOutlineForSurface(context, cardSurface)
                    : scheme.outlineVariant.withValues(alpha: 0.55)),
            width: neo ? shapes.outlineWidth : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: expressiveTokens == null ? 56 : 48,
              height: expressiveTokens == null ? 56 : 48,
              decoration: BoxDecoration(
                color:
                    expressiveTokens?.planFocalSurface ??
                    (neo
                        ? surfaces.dialogChoice
                        : scheme.primary.withValues(alpha: 0.18)),
                borderRadius: expressiveTokens?.rowShape,
                shape: expressiveTokens == null
                    ? BoxShape.circle
                    : BoxShape.rectangle,
              ),
              child: Icon(
                icon,
                color:
                    expressiveTokens?.planFocalForeground ??
                    (neo ? cardForeground : scheme.primary),
                size: expressiveTokens == null ? 28 : 24,
              ),
            ),
            SizedBox(height: expressiveTokens == null ? 16 : 12),
            Text(
              title,
              style:
                  (expressiveTokens == null
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleLarge)
                      ?.copyWith(
                        color: expressiveTokens != null || neo
                            ? cardForeground
                            : null,
                        fontWeight: expressiveTokens == null
                            ? FontWeight.w900
                            : FontWeight.w800,
                      ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: expressiveTokens != null || neo ? cardSecondary : null,
              ),
            ),
            SizedBox(height: expressiveTokens == null ? 20 : 16),
            if (actionHint != null) ...[
              Text(
                actionHint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cardSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.suffixText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final neo = context.usesNeoPresentation;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: settingsInputTextStyle(context),
      decoration: neo
          ? settingsFieldDecoration(
              context,
              label: label,
              hint: hint,
              suffixText: suffixText,
            ).copyWith(prefixIcon: Icon(icon))
          : _onboardingInputDecoration(
              context,
              label: label,
              hint: hint,
              icon: icon,
              suffixText: suffixText,
            ),
    );
  }
}

class _ActionField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ActionField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neo = context.usesNeoPresentation;
    final decoration = neo
        ? settingsFieldDecoration(
            context,
            label: label,
          ).copyWith(prefixIcon: Icon(icon))
        : _onboardingInputDecoration(context, label: label, icon: icon);
    return InkWell(
      borderRadius: context.tutorialTokens.inputShape,
      onTap: onTap,
      child: InputDecorator(
        decoration: decoration,
        child: Text(value, style: settingsInputTextStyle(context)),
      ),
    );
  }
}

class _IntentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool value;
  final bool enabled;
  final String? statusLabel;
  final ValueChanged<bool> onChanged;

  const _IntentTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final selected = enabled && value;
    final tileSurface = expressive != null
        ? (selected
              ? expressive.selectedSurface
              : Color.lerp(
                  expressive.planSupportSurface,
                  expressive.pageCanvas,
                  enabled ? 0.55 : 0.85,
                )!)
        : neo
        ? (selected ? surfaces.settingsHero : surfaces.dialogChoice)
        : null;
    final expressiveForeground = selected && expressive != null
        ? _expressiveSelectedForeground(context, expressive)
        : expressive?.planSupportForeground;
    final iconColor = expressive != null
        ? expressiveForeground!.withValues(alpha: enabled ? 1 : 0.7)
        : neo
        ? tonosForegroundForSurface(context, tileSurface!)
        : enabled
        ? scheme.primary
        : scheme.onSurfaceVariant;
    final foregroundColor = expressive != null
        ? expressiveForeground!.withValues(alpha: enabled ? 1 : 0.85)
        : neo
        ? tonosForegroundForSurface(context, tileSurface!)
        : enabled
        ? scheme.onSurface
        : scheme.onSurfaceVariant;
    final secondaryColor = expressive != null
        ? expressiveForeground!.withValues(alpha: enabled ? 0.88 : 0.62)
        : neo
        ? tonosSecondaryForegroundForSurface(context, tileSurface!)
        : scheme.onSurfaceVariant.withValues(alpha: enabled ? 1 : 0.78);
    final borderColor = expressive != null
        ? expressive.outline.withValues(alpha: selected ? 1 : 0.4)
        : neo
        ? tonosOutlineForSurface(context, tileSurface!)
        : selected
        ? scheme.primary
        : scheme.outlineVariant;
    final backgroundColor = expressive != null
        ? tileSurface
        : neo
        ? tileSurface
        : selected
        ? scheme.primary.withValues(alpha: 0.16)
        : scheme.surface.withValues(alpha: enabled ? 0.5 : 0.28);

    return InkWell(
      borderRadius:
          expressive?.rowShape ??
          (neo ? shapes.settingsInput : context.tutorialTokens.tileShape),
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: _onboardingSelectionMotion(context),
        curve: context.usesExpressivePresentation
            ? TonosExpressiveStateMotion.effects
            : Curves.linear,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              expressive?.rowShape ??
              (neo ? shapes.settingsInput : context.tutorialTokens.tileShape),
          border: Border.all(
            color: borderColor,
            width: expressive != null
                ? (selected ? 1.5 : 1)
                : neo
                ? shapes.outlineWidth
                : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.16),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled && statusLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: neo
                      ? surfaces.settingsInput
                      : scheme.surfaceContainerHighest,
                  borderRadius: neo
                      ? shapes.pill
                      : context.tutorialTokens.pillShape,
                  border: Border.all(
                    color: neo
                        ? tonosOutlineForSurface(
                            context,
                            surfaces.settingsInput,
                          )
                        : scheme.outlineVariant,
                    width: neo ? shapes.outlineWidth : 1,
                  ),
                ),
                child: Text(
                  statusLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: neo
                        ? tonosForegroundForSurface(
                            context,
                            surfaces.settingsInput,
                          )
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              Checkbox(
                value: value,
                onChanged: enabled ? (next) => onChanged(next ?? false) : null,
                fillColor: expressive != null
                    ? WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? foregroundColor
                            : Colors.transparent,
                      )
                    : neo
                    ? WidgetStatePropertyAll<Color?>(foregroundColor)
                    : null,
                checkColor: expressive != null
                    ? tileSurface
                    : neo
                    ? surfaces.dialogChoice
                    : null,
                side: expressive == null
                    ? null
                    : BorderSide(color: foregroundColor),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final cardSurface =
        expressive?.planSupportSurface ??
        (neo ? surfaces.settingsInput : scheme.surface);
    final cardForeground = expressive != null
        ? expressive.planSupportForeground
        : neo
        ? tonosForegroundForSurface(context, cardSurface)
        : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: expressive != null
            ? cardSurface
            : neo
            ? cardSurface
            : scheme.surface.withValues(alpha: 0.5),
        borderRadius:
            expressive?.rowShape ??
            (neo ? shapes.settingsInput : context.tutorialTokens.sectionShape),
        border: Border.all(
          color: expressive != null
              ? expressive.outline
              : neo
              ? tonosOutlineForSurface(context, cardSurface)
              : scheme.outlineVariant.withValues(alpha: 0.7),
          width: expressive != null
              ? 1.5
              : neo
              ? shapes.outlineWidth
              : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: expressive != null || neo ? cardForeground : null,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (expressive == null)
            Switch(value: value, onChanged: onChanged)
          else
            SwitchTheme(
              data: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? expressive.actionPrimaryForeground
                      : expressive.planSupportForeground;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? expressive.actionPrimary
                      : expressive.planSupportSurface;
                }),
                trackOutlineColor: WidgetStatePropertyAll<Color?>(
                  expressive.outline,
                ),
              ),
              child: Switch(value: value, onChanged: onChanged),
            ),
        ],
      ),
    );
  }
}

class _ChoiceGroup<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T option)? labelBuilder;

  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: neo
                ? tonosForegroundForSurface(context, surfaces.settingsSection)
                : null,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = option == value;
            final chipSurface = expressive != null
                ? (selected
                      ? expressive.selectedSurface
                      : expressive.planSupportSurface)
                : neo
                ? (selected ? surfaces.settingsHero : surfaces.dialogChoice)
                : null;
            return ChoiceChip(
              label: Text(
                labelBuilder?.call(option) ?? '$option',
                style: expressive != null
                    ? TextStyle(
                        color: selected
                            ? _expressiveSelectedForeground(context, expressive)
                            : expressive.planSupportForeground,
                        fontWeight: FontWeight.w800,
                      )
                    : neo
                    ? TextStyle(
                        color: tonosForegroundForSurface(context, chipSurface!),
                        fontWeight: FontWeight.w800,
                      )
                    : null,
              ),
              selected: selected,
              checkmarkColor: expressive == null
                  ? null
                  : _expressiveSelectedForeground(context, expressive),
              onSelected: (_) => onChanged(option),
              selectedColor: expressive != null || neo ? chipSurface : null,
              backgroundColor: expressive != null || neo ? chipSurface : null,
              shape: expressive == null
                  ? null
                  : RoundedRectangleBorder(borderRadius: expressive.rowShape),
              side: expressive != null
                  ? BorderSide(
                      color: expressive.outline.withValues(
                        alpha: selected ? 1 : 0.4,
                      ),
                      width: selected ? 1.5 : 1,
                    )
                  : neo
                  ? BorderSide(
                      color: tonosOutlineForSurface(context, chipSurface!),
                      width: shapes.outlineWidth,
                    )
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BodyFatTile extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyFatTile({
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: context.tutorialTokens.inputShape,
      onTap: onTap,
      child: AnimatedContainer(
        duration: _onboardingSelectionMotion(context),
        curve: context.usesExpressivePresentation
            ? TonosExpressiveStateMotion.effects
            : Curves.linear,
        decoration: BoxDecoration(
          borderRadius: context.tutorialTokens.inputShape,
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Icons.image_not_supported, color: scheme.outline),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.58),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPreviewCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricPreviewCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final cardSurface = neo ? surfaces.dialogChoice : scheme.surface;
    final cardForeground = neo
        ? tonosForegroundForSurface(context, cardSurface)
        : scheme.onSurface;
    final cardSecondary = neo
        ? tonosSecondaryForegroundForSurface(context, cardSurface)
        : scheme.onSurfaceVariant;
    final shapes = context.shapeTokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: neo ? cardSurface : scheme.primary.withValues(alpha: 0.14),
        borderRadius: neo
            ? shapes.settingsInput
            : context.tutorialTokens.sectionShape,
        border: neo
            ? Border.all(
                color: tonosOutlineForSurface(context, cardSurface),
                width: shapes.outlineWidth,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: neo ? cardForeground : scheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: neo ? cardForeground : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: cardSecondary),
          ),
        ],
      ),
    );
  }
}

class _SliderPanel extends StatelessWidget {
  final String title;
  final String valueLabel;
  final Widget child;

  const _SliderPanel({
    required this.title,
    required this.valueLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final panelSurface = neo ? surfaces.settingsSection : scheme.surface;
    final panelForeground = neo
        ? tonosForegroundForSurface(context, panelSurface)
        : scheme.onSurface;
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      color: neo ? panelForeground : null,
      fontWeight: FontWeight.w900,
    );
    final valueStyle = theme.textTheme.titleSmall?.copyWith(
      color: neo ? panelForeground : scheme.primary,
      fontWeight: FontWeight.w900,
    );
    final titleWidget = Text(title, style: titleStyle);
    final valueWidget = Text(valueLabel, style: valueStyle);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: neo ? panelSurface : scheme.surface.withValues(alpha: 0.52),
        borderRadius: neo
            ? shapes.settingsInput
            : context.tutorialTokens.sectionShape,
        border: Border.all(
          color: neo
              ? tonosOutlineForSurface(context, panelSurface)
              : scheme.outlineVariant.withValues(alpha: 0.65),
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final valuePainter = TextPainter(
                text: TextSpan(text: valueLabel, style: valueStyle),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: 1,
              );
              valuePainter.layout();
              final titlePainter = TextPainter(
                text: TextSpan(text: title, style: titleStyle),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              );
              titlePainter.layout();
              // Keep the original row while a complete title word still fits.
              final stackHeader =
                  valuePainter.width + titlePainter.minIntrinsicWidth >
                  constraints.maxWidth;
              valuePainter.dispose();
              titlePainter.dispose();
              if (stackHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleWidget,
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: valueWidget,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: titleWidget),
                  valueWidget,
                ],
              );
            },
          ),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final statSurface = neo ? surfaces.dialogChoice : scheme.surface;
    final statForeground = neo
        ? tonosForegroundForSurface(context, statSurface)
        : scheme.onSurface;
    final statSecondary = neo
        ? tonosSecondaryForegroundForSurface(context, statSurface)
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: neo ? statSurface : scheme.surface.withValues(alpha: 0.52),
        borderRadius: neo
            ? shapes.settingsInput
            : context.tutorialTokens.inputShape,
        border: Border.all(
          color: neo
              ? tonosOutlineForSurface(context, statSurface)
              : scheme.outlineVariant.withValues(alpha: 0.65),
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: neo ? statForeground : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: statSecondary),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final featureSurface = neo ? surfaces.settingsSection : scheme.surface;
    final featureForeground = neo
        ? tonosForegroundForSurface(context, featureSurface)
        : scheme.onSurface;
    final featureSecondary = neo
        ? tonosSecondaryForegroundForSurface(context, featureSurface)
        : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: neo ? featureForeground : scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: neo ? featureForeground : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: featureSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final summarySurface = neo ? surfaces.settingsSection : scheme.surface;
    final summarySecondary = expressive != null
        ? expressive.onPage.withValues(alpha: 0.8)
        : neo
        ? tonosSecondaryForegroundForSurface(context, summarySurface)
        : scheme.onSurfaceVariant;
    final summaryForeground = expressive != null
        ? expressive.onPage
        : neo
        ? tonosForegroundForSurface(context, summarySurface)
        : scheme.onSurface;
    final valueText = value.trim().isEmpty ? '-' : value;
    final usesStackedLayout =
        MediaQuery.textScalerOf(context).scale(1) > 1.15 ||
        MediaQuery.sizeOf(context).width < 360;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: summarySecondary,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: expressive != null || neo ? summaryForeground : null,
      fontWeight: FontWeight.w800,
    );

    if (usesStackedLayout) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 2),
            Text(valueText, style: valueStyle),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: Text(valueText, style: valueStyle)),
        ],
      ),
    );
  }
}

class _OnboardingSummaryCallout extends StatelessWidget {
  final String label;
  final String value;

  const _OnboardingSummaryCallout({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final calloutSurface =
        expressive?.planFocalSurface ??
        (neo ? surfaces.dialogChoice : scheme.surface);
    final calloutForeground = expressive != null
        ? expressive.planFocalForeground
        : neo
        ? tonosForegroundForSurface(context, calloutSurface)
        : scheme.onSurface;
    final calloutSecondary = expressive != null
        ? expressive.planFocalForeground.withValues(alpha: 0.85)
        : neo
        ? tonosSecondaryForegroundForSurface(context, calloutSurface)
        : scheme.onSurfaceVariant;
    final shapes = context.shapeTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expressive != null || neo
            ? calloutSurface
            : scheme.primary.withValues(alpha: 0.12),
        borderRadius:
            expressive?.rowShape ??
            (neo ? shapes.settingsInput : context.tutorialTokens.compactShape),
        border: Border.all(
          color: expressive != null
              ? expressive.outline.withValues(alpha: 0.3)
              : neo
              ? tonosOutlineForSurface(context, calloutSurface)
              : scheme.primary.withValues(alpha: 0.3),
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: expressive != null || neo
                ? calloutForeground
                : scheme.primary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: expressive != null || neo
                        ? calloutForeground
                        : scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: calloutSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSummarySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool prominent;

  const _OnboardingSummarySection({
    required this.icon,
    required this.title,
    required this.children,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final sectionSurface = expressive != null
        ? (prominent
              ? expressive.configurationSurface
              : Color.lerp(
                  expressive.planSupportSurface,
                  expressive.pageCanvas,
                  0.65,
                )!)
        : neo
        ? surfaces.settingsInput
        : scheme.surface;
    final sectionForeground = expressive != null
        ? expressive.onPage
        : neo
        ? tonosForegroundForSurface(context, sectionSurface)
        : scheme.onSurface;
    final shapes = context.shapeTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 4),
      decoration: BoxDecoration(
        color: expressive != null || neo
            ? sectionSurface
            : scheme.surface.withValues(alpha: 0.46),
        borderRadius:
            expressive?.rowShape ??
            (neo ? shapes.settingsInput : context.tutorialTokens.inputShape),
        border: Border.all(
          color: expressive != null
              ? expressive.outline.withValues(alpha: 0.3)
              : neo
              ? tonosOutlineForSurface(context, sectionSurface)
              : scheme.outlineVariant.withValues(alpha: 0.6),
          width: neo ? shapes.outlineWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: expressive != null || neo
                    ? sectionForeground
                    : scheme.primary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: expressive != null || neo ? sectionForeground : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              color: expressive != null
                  ? expressive.outline.withValues(alpha: 0.25)
                  : neo
                  ? tonosOutlineForSurface(context, sectionSurface)
                  : null,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final neo = context.usesNeoPresentation;
    final surfaces = context.surfaceTokens;
    final activeColor = neo ? surfaces.settingsHero : scheme.primary;
    final inactiveColor = neo
        ? tonosOutlineForSurface(context, surfaces.settingsSection)
        : scheme.outlineVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: _onboardingSelectionMotion(context),
          curve: context.usesExpressivePresentation
              ? TonosExpressiveStateMotion.effects
              : Curves.linear,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: context.tutorialTokens.pillShape,
          ),
        );
      }),
    );
  }
}

class _GymSpaceTile extends StatelessWidget {
  final _GymSpaceTemplate template;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _GymSpaceTile({
    required this.template,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surfaces = context.surfaceTokens;
    final shapes = context.shapeTokens;
    final accent = template.highlighted ? scheme.tertiary : scheme.primary;
    final tileSurface = expressive != null
        ? (selected
              ? expressive.selectedSurface
              : Color.lerp(
                  expressive.planSupportSurface,
                  expressive.pageCanvas,
                  0.55,
                )!)
        : neo
        ? (selected ? surfaces.settingsHero : surfaces.dialogChoice)
        : null;
    final tileForeground = expressive != null
        ? (selected
              ? _expressiveSelectedForeground(context, expressive)
              : expressive.planSupportForeground)
        : neo
        ? tonosForegroundForSurface(context, tileSurface!)
        : scheme.onSurface;
    final tileSecondary = expressive != null
        ? tileForeground.withValues(alpha: 0.82)
        : neo
        ? tonosSecondaryForegroundForSurface(context, tileSurface!)
        : scheme.onSurfaceVariant;
    final tileBorder = expressive != null
        ? expressive.outline.withValues(alpha: selected ? 1 : 0.4)
        : neo
        ? tonosOutlineForSurface(context, tileSurface!)
        : selected
        ? accent
        : scheme.outlineVariant;
    final tileBackground = expressive != null
        ? tileSurface
        : neo
        ? tileSurface
        : selected
        ? accent.withValues(alpha: 0.16)
        : scheme.surface.withValues(alpha: 0.46);
    final tileShape =
        expressive?.rowShape ??
        (neo ? shapes.settingsInput : context.tutorialTokens.tileShape);

    return InkWell(
      onTap: onTap,
      borderRadius: tileShape,
      child: AnimatedContainer(
        duration: _onboardingSelectionMotion(context),
        curve: context.usesExpressivePresentation
            ? TonosExpressiveStateMotion.effects
            : Curves.linear,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: tileShape,
          border: Border.all(
            color: tileBorder,
            width: expressive != null
                ? (selected ? 1.5 : 1)
                : neo
                ? shapes.outlineWidth
                : selected
                ? 2
                : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: expressive != null
                    ? expressive.actionSecondary
                    : (neo ? tileForeground : accent).withValues(alpha: 0.16),
                borderRadius: expressive != null
                    ? shapes.control
                    : neo
                    ? shapes.control
                    : context.tutorialTokens.compactShape,
              ),
              child: Icon(
                template.icon,
                color: expressive != null
                    ? expressive.actionSecondaryForeground
                    : neo
                    ? tileForeground
                    : accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: expressive != null || neo
                          ? tileForeground
                          : template.highlighted
                          ? accent
                          : null,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tileSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: expressive != null
                  ? (selected
                        ? _expressiveSelectedForeground(context, expressive)
                        : tileSecondary)
                  : neo
                  ? tileForeground
                  : selected
                  ? accent
                  : tileSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _GymEquipmentLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GymEquipmentLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.32),
        borderRadius: context.tutorialTokens.sectionShape,
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: scheme.error),
          const SizedBox(height: 8),
          Text(
            strings.onboardingEquipmentLoadError,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(strings.onboardingTryAgain),
          ),
        ],
      ),
    );
  }
}

class _OnboardingInfoCallout extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OnboardingInfoCallout({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final calloutSurface =
        expressive?.configurationSurface ??
        scheme.primary.withValues(alpha: 0.12);
    final parentSurface = neo
        ? context.surfaceTokens.settingsSection
        : scheme.surface;
    final iconInk = expressive != null
        ? expressive.configurationForeground
        : neo
        ? tonosForegroundForSurface(
            context,
            calloutSurface,
            parentSurface: parentSurface,
          )
        : scheme.primary;
    final messageInk = expressive != null
        ? expressive.configurationForeground
        : neo
        ? tonosSecondaryForegroundForSurface(
            context,
            calloutSurface,
            parentSurface: parentSurface,
          )
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: calloutSurface,
        borderRadius:
            expressive?.supportShape ?? context.tutorialTokens.inputShape,
        border: Border.all(
          color:
              expressive?.outline.withValues(alpha: 0.35) ??
              scheme.primary.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: messageInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingEquipmentSummary extends StatelessWidget {
  final String heading;
  final String count;
  final String description;
  final List<Widget> content;
  final Widget? action;

  const _OnboardingEquipmentSummary({
    required this.heading,
    required this.count,
    required this.description,
    required this.content,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final surface =
        expressive?.equipmentSurface ?? scheme.surface.withValues(alpha: 0.46);
    final foreground = expressive?.equipmentForeground ?? scheme.onSurface;
    final secondary = expressive != null
        ? foreground.withValues(alpha: 0.82)
        : scheme.onSurfaceVariant;
    final shape =
        expressive?.supportShape ?? context.tutorialTokens.sectionShape;

    return Container(
      key: const Key('onboarding-included-equipment'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: shape,
        border: Border.all(
          color:
              expressive?.outline.withValues(alpha: 0.4) ??
              scheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: expressive != null ? foreground : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                count,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: expressive?.equipmentForeground ?? scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (action != null) ...[const SizedBox(width: 8), action!],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(color: secondary),
          ),
          const SizedBox(height: 14),
          ...content,
        ],
      ),
    );
  }
}

class _OnboardingSkipSetupDialog extends StatelessWidget {
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _OnboardingSkipSetupDialog({
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final dialog = AlertDialog(
      backgroundColor: expressive?.planFocalSurface,
      shape: expressive == null
          ? null
          : RoundedRectangleBorder(borderRadius: expressive.supportShape),
      titleTextStyle: expressive == null
          ? null
          : theme.textTheme.headlineSmall?.copyWith(
              color: expressive.planFocalForeground,
              fontWeight: FontWeight.w900,
            ),
      contentTextStyle: expressive == null
          ? null
          : theme.textTheme.bodyLarge?.copyWith(
              color: expressive.planFocalForeground.withValues(alpha: 0.9),
            ),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: expressive == null
              ? null
              : TextButton.styleFrom(
                  foregroundColor: expressive.planFocalForeground,
                ),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: expressive == null
              ? null
              : FilledButton.styleFrom(
                  backgroundColor: expressive.actionSecondary,
                  foregroundColor: expressive.actionSecondaryForeground,
                ),
          child: Text(confirmLabel),
        ),
      ],
    );

    return TonosDialogFrame(child: dialog);
  }
}

Color _expressiveSelectedForeground(
  BuildContext context,
  AppExpressivePlanningTokens tokens,
) => Theme.of(context).brightness == Brightness.dark
    ? tokens.planAccentForeground
    : tokens.planFocalForeground;

IconData _onboardingEquipmentIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('bench')) return Icons.event_seat;
  if (lower.contains('machine') || lower.contains('smith')) {
    return Icons.precision_manufacturing;
  }
  if (lower.contains('cable') || lower.contains('attachment')) {
    return Icons.cable;
  }
  if (lower.contains('bodyweight') || lower == 'none') {
    return Icons.accessibility_new;
  }
  if (lower.contains('ring')) return Icons.radio_button_unchecked;
  if (lower.contains('band')) return Icons.linear_scale;
  if (lower.contains('rack') || lower.contains('pull-up')) {
    return Icons.view_week;
  }
  return Icons.fitness_center;
}
