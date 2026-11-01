import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/flow_method_draft.dart';
import '../../../../models/preset_models.dart';
import '../../../../repositories/app_repository.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../../theme/widgets/tonos_dialog.dart';
import '../../../../theme/widgets/tonos_field.dart';
import 'rule_editor_controls.dart';

enum _CopySetSource { last, first, specific }

/// Dialog for adding or editing a workout progress rule on a plan.
class AddPresetMethodDialog extends StatefulWidget {
  final int presetId;
  final FlowMethod? existing;
  const AddPresetMethodDialog({
    super.key,
    required this.presetId,
    this.existing,
  });

  @override
  AddPresetMethodDialogState createState() => AddPresetMethodDialogState();
}

class AddPresetMethodDialogState extends State<AddPresetMethodDialog> {
  AppRepository get _repo => context.read<AppRepository>();

  bool _nameEdited = false;
  late TextEditingController _nameCtl;
  late MethodType _type;
  late String _sign;
  late TextEditingController _factorCtl;
  late TextEditingController _amountCtl;
  AddSetMode _addMode = AddSetMode.explicit;
  late TextEditingController _weightCtl;
  late TextEditingController _repsCtl;
  late TextEditingController _copyIndexCtl;
  late TextEditingController _copySetNumberCtl;
  late _CopySetSource _copySource;
  bool _copyNumberEdited = false;

  int? get _copySetNumber => int.tryParse(_copySetNumberCtl.text.trim());

  bool get _copySetNumberIsValid => (_copySetNumber ?? 0) >= 1;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _nameCtl = TextEditingController(text: ex?.name);
    _type = ex?.type ?? MethodType.weight;
    _sign = ex?.params['sign'] as String? ?? '+';
    _factorCtl = TextEditingController(text: ex?.params['factor']?.toString());
    _amountCtl = TextEditingController(text: ex?.params['amount']?.toString());
    _addMode = ex?.params.containsKey('copyFromSetIndex') == true
        ? AddSetMode.copy
        : AddSetMode.explicit;
    _weightCtl = TextEditingController(text: ex?.params['weight']?.toString());
    _repsCtl = TextEditingController(text: ex?.params['reps']?.toString());
    _copyIndexCtl = TextEditingController(
      text: ex?.params['copyFromSetIndex']?.toString() ?? '-1',
    );
    final copyIndex = (ex?.params['copyFromSetIndex'] as num?)?.toInt() ?? -1;
    _copySource = copyIndex < 0
        ? _CopySetSource.last
        : copyIndex == 0
        ? _CopySetSource.first
        : _CopySetSource.specific;
    _copySetNumberCtl = TextEditingController(
      text: copyIndex >= 0 ? '${copyIndex + 1}' : '',
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _factorCtl.dispose();
    _amountCtl.dispose();
    _weightCtl.dispose();
    _repsCtl.dispose();
    _copyIndexCtl.dispose();
    _copySetNumberCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    if (expressive) return _buildExpressiveDialog(strings);
    final fieldGap = expressive ? 8.0 : 12.0;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosField(controller: _nameCtl, labelText: strings.commonName),
        SizedBox(height: fieldGap),
        FlowMethodsChoiceField<MethodType>(
          title: strings.rulesRuleTypeLabel,
          values: MethodType.values,
          value: _type,
          label: (value) => flowMethodTypeLabel(value, strings),
          onChanged: (value) {
            if (value != null) setState(() => _type = value);
          },
          nonExpressiveButton: () => TonosDialogDropdownButton<MethodType>(
            value: _type,
            onChanged: (value) => setState(() => _type = value!),
            items: MethodType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(flowMethodTypeLabel(t, strings)),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: fieldGap),
        if (_type == MethodType.weight) ...[
          FlowMethodsChoiceField<String>(
            title: strings.rulesOperationLabel,
            values: const ['+', '-'],
            value: _sign,
            label: (value) => value,
            onChanged: (value) {
              if (value != null) setState(() => _sign = value);
            },
            nonExpressiveButton: () => TonosDialogDropdownButton<String>(
              value: _sign,
              onChanged: (value) => setState(() => _sign = value!),
              items: const [
                DropdownMenuItem(value: '+', child: Text('+')),
                DropdownMenuItem(value: '-', child: Text('-')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TonosField(
            controller: _factorCtl,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            labelText: strings.flowFactor,
          ),
        ] else if (_type == MethodType.rep) ...[
          FlowMethodsChoiceField<String>(
            title: strings.rulesOperationLabel,
            values: const ['+', '-'],
            value: _sign,
            label: (value) => value,
            onChanged: (value) {
              if (value != null) setState(() => _sign = value);
            },
            nonExpressiveButton: () => TonosDialogDropdownButton<String>(
              value: _sign,
              onChanged: (value) => setState(() => _sign = value!),
              items: const [
                DropdownMenuItem(value: '+', child: Text('+')),
                DropdownMenuItem(value: '-', child: Text('-')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TonosField(
            controller: _amountCtl,
            keyboardType: TextInputType.number,
            labelText: strings.flowAmount,
          ),
        ] else if (_type == MethodType.addSet) ...[
          buildRuleAddSetModeOptions(
            context,
            selected: _addMode,
            onChanged: (value) => setState(() => _addMode = value),
          ),
          const SizedBox(height: 8),
          if (_addMode == AddSetMode.explicit) ...[
            TonosField(
              controller: _weightCtl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              labelText: strings.flowWeight,
            ),
            const SizedBox(height: 8),
            TonosField(
              controller: _repsCtl,
              keyboardType: TextInputType.number,
              labelText: strings.flowReps,
            ),
          ] else ...[
            TonosField(
              controller: _copyIndexCtl,
              keyboardType: TextInputType.number,
              labelText: strings.rulesCopyIndex,
            ),
          ],
        ] else if (_type == MethodType.delSet) ...[
          Text(strings.rulesDeleteLastSetBody),
        ],
      ],
    );
    return AlertDialog(
      scrollable: expressive,
      title: Text(isEdit ? strings.rulesEditPlan : strings.rulesAddPlanTitle),
      content: expressive ? content : SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.commonCancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(strings.commonSave)),
      ],
    );
  }

  Widget _buildExpressiveDialog(AppLocalizations strings) {
    final theme = Theme.of(context);
    final tokens = AppExpressiveDestinationTokens.forFamily(
      AppExpressiveDestinationFamily.profile,
      theme.brightness,
    );
    final fieldSurface = Color.alphaBlend(
      tokens.pageCanvas.withValues(alpha: 0.5),
      tokens.surfaceTertiary,
    );
    final outline = tokens.outlineAccent.withValues(alpha: 0.45);
    const radius = BorderRadius.all(Radius.circular(18));
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? tokens.surfaceTertiary
            : fieldSurface,
      ),
      constraints: const BoxConstraints(minHeight: 52),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(outline),
      enabledBorder: border(outline),
      focusedBorder: border(tokens.actionPrimary, 2),
      disabledBorder: border(tokens.outlineAccent.withValues(alpha: 0.22)),
      errorBorder: border(theme.colorScheme.error),
      focusedErrorBorder: border(theme.colorScheme.error, 2),
      errorMaxLines: 3,
    );
    Widget field(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: tokens.onSurfaceTertiary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
    Widget numberField(
      String label,
      TextEditingController controller, {
      bool decimal = false,
      String? helperText,
      String? errorText,
      ValueChanged<String>? onChanged,
    }) => field(
      label,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TonosField(
            controller: controller,
            semanticLabel: label,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            textInputAction: TextInputAction.done,
            errorText: errorText,
            onChanged: onChanged,
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.supportingForeground,
              ),
            ),
          ],
        ],
      ),
    );
    Widget operationField() => field(
      strings.rulesOperationLabel,
      FlowMethodsChoiceField<String>(
        title: strings.rulesOperationLabel,
        values: const ['+', '-'],
        value: _sign,
        label: (value) => value == '+'
            ? '+  ${strings.commonAdd}'
            : '−  ${strings.rulesOperationSubtract}',
        onChanged: (value) {
          if (value != null) setState(() => _sign = value);
        },
        planRuleStyle: true,
        scrollFieldIntoUpperArea: true,
        nonExpressiveButton: () => const SizedBox.shrink(),
      ),
    );
    final disabledSurface = Color.alphaBlend(
      tokens.actionPrimary.withValues(alpha: 0.12),
      tokens.surfaceTertiary,
    );
    final disabledForeground = Color.alphaBlend(
      tokens.onSurfaceTertiary.withValues(alpha: 0.6),
      disabledSurface,
    );
    final nameIsEmpty = _nameCtl.text.trim().isEmpty;
    final copyNumberIsInvalid =
        _type == MethodType.addSet &&
        _addMode == AddSetMode.copy &&
        _copySource == _CopySetSource.specific &&
        !_copySetNumberIsValid;

    return Theme(
      data: theme.copyWith(inputDecorationTheme: inputTheme),
      child: AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints(maxWidth: 440),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actionsOverflowButtonSpacing: 8,
        title: Text(
          widget.existing == null
              ? strings.rulesAddPlanTitle
              : strings.rulesEditPlan,
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field(
                strings.commonName,
                TonosField(
                  controller: _nameCtl,
                  semanticLabel: strings.commonName,
                  textInputAction: TextInputAction.next,
                  errorText: _nameEdited && nameIsEmpty
                      ? strings.rulesNameRequired
                      : null,
                  onChanged: (_) => setState(() => _nameEdited = true),
                ),
              ),
              const SizedBox(height: 16),
              field(
                strings.rulesRuleTypeLabel,
                FlowMethodsChoiceField<MethodType>(
                  title: strings.rulesRuleTypeLabel,
                  values: MethodType.values,
                  value: _type,
                  label: (value) => flowMethodTypeLabel(value, strings),
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                  planRuleStyle: true,
                  nonExpressiveButton: () => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
              if (_type == MethodType.weight) ...[
                operationField(),
                const SizedBox(height: 16),
                numberField(
                  strings.flowFactor,
                  _factorCtl,
                  decimal: true,
                  helperText: strings.rulesFactorHelper,
                ),
              ] else if (_type == MethodType.rep) ...[
                operationField(),
                const SizedBox(height: 16),
                numberField(
                  strings.flowAmount,
                  _amountCtl,
                  helperText: strings.rulesAmountHelper,
                ),
              ] else if (_type == MethodType.addSet) ...[
                buildRuleAddSetModeOptions(
                  context,
                  selected: _addMode,
                  onChanged: (value) => setState(() => _addMode = value),
                  expressiveSelectionGroup: true,
                ),
                const SizedBox(height: 16),
                if (_addMode == AddSetMode.explicit) ...[
                  numberField(strings.flowWeight, _weightCtl, decimal: true),
                  const SizedBox(height: 16),
                  numberField(strings.flowReps, _repsCtl),
                ] else ...[
                  field(
                    strings.rulesCopyFromLabel,
                    FlowMethodsChoiceField<_CopySetSource>(
                      title: strings.rulesCopyFromLabel,
                      values: _CopySetSource.values,
                      value: _copySource,
                      label: (value) => switch (value) {
                        _CopySetSource.last => strings.rulesCopyFromLastSet,
                        _CopySetSource.first => strings.rulesCopyFromFirstSet,
                        _CopySetSource.specific =>
                          strings.rulesCopyFromSpecificSet,
                      },
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _copySource = value);
                        }
                      },
                      planRuleStyle: true,
                      scrollFieldIntoUpperArea: true,
                      nonExpressiveButton: () => const SizedBox.shrink(),
                    ),
                  ),
                  if (_copySource == _CopySetSource.specific) ...[
                    const SizedBox(height: 16),
                    numberField(
                      strings.rulesCopySetNumberLabel,
                      _copySetNumberCtl,
                      helperText: strings.rulesCopySpecificHelper,
                      errorText: _copyNumberEdited && copyNumberIsInvalid
                          ? strings.rulesCopySetNumberInvalid
                          : null,
                      onChanged: (_) =>
                          setState(() => _copyNumberEdited = true),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      _copySource == _CopySetSource.last
                          ? strings.rulesCopyFromLastHelper
                          : strings.rulesCopyFromFirstHelper,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.supportingForeground,
                      ),
                    ),
                  ],
                ],
              ] else
                Text(
                  strings.rulesDeleteLastSetBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.onSurfaceTertiary,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.onSurfaceTertiary,
              side: BorderSide(color: outline),
              minimumSize: const Size(88, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.compactControl,
              ),
            ),
            child: Text(strings.commonCancel),
          ),
          FilledButton(
            onPressed: nameIsEmpty || copyNumberIsInvalid ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: tokens.actionPrimary,
              foregroundColor: tokens.onActionPrimary,
              disabledBackgroundColor: disabledSurface,
              disabledForegroundColor: disabledForeground,
              minimumSize: const Size(88, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: ExpressiveTrainShapes.compactControl,
              ),
            ),
            child: Text(strings.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.rulesNameRequired)));
      return;
    }
    final expressiveCopy =
        context.usesExpressivePresentation &&
        _type == MethodType.addSet &&
        _addMode == AddSetMode.copy;
    if (expressiveCopy &&
        _copySource == _CopySetSource.specific &&
        !_copySetNumberIsValid) {
      setState(() => _copyNumberEdited = true);
      return;
    }
    final draft = FlowMethodDraft.fromEditor(
      name: name,
      type: _type,
      sign: _sign,
      factorText: _factorCtl.text,
      amountText: _amountCtl.text,
      weightText: _weightCtl.text,
      repsText: _repsCtl.text,
      copyExistingSet: _addMode == AddSetMode.copy,
      copyIndexText: _copyIndexCtl.text,
      copyIndexOverride: expressiveCopy
          ? switch (_copySource) {
              _CopySetSource.last => -1,
              _CopySetSource.first => 0,
              _CopySetSource.specific => _copySetNumber! - 1,
            }
          : null,
    );
    final saved = await _repo.saveFlowMethodAtomic(
      presetId: widget.presetId,
      name: name,
      type: _type,
      params: draft.toParameters(),
      previousMethodId: widget.existing?.id,
      previousName: widget.existing?.name,
    );
    if (!mounted) return;
    navigator.pop(saved);
  }
}
