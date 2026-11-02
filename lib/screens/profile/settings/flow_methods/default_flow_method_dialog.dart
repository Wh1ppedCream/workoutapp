import 'package:material_ui/material_ui.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/flow_method_draft.dart';
import '../../../../models/preset_models.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../theme/widgets/tonos_dialog.dart';
import '../../../../theme/widgets/tonos_field.dart';
import 'rule_editor_controls.dart';

/// Edits a default rule draft. The page owns persistence and propagation.
class DefaultFlowMethodDialog extends StatefulWidget {
  const DefaultFlowMethodDialog({
    super.key,
    required this.title,
    this.existing,
  });

  final String title;
  final FlowMethod? existing;

  @override
  State<DefaultFlowMethodDialog> createState() =>
      _DefaultFlowMethodDialogState();
}

class _DefaultFlowMethodDialogState extends State<DefaultFlowMethodDialog> {
  late final TextEditingController _name;
  late final TextEditingController _factor;
  late final TextEditingController _amount;
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  late final TextEditingController _copyIndex;
  late MethodType _type;
  late String _sign;
  late AddSetMode _addMode;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name);
    _factor = TextEditingController(
      text: existing?.params['factor']?.toString() ?? '1.0',
    );
    _amount = TextEditingController(
      text: existing?.params['amount']?.toString() ?? '0',
    );
    _weight = TextEditingController(
      text: existing?.params['weight']?.toString() ?? '0.0',
    );
    _reps = TextEditingController(
      text: existing?.params['reps']?.toString() ?? '0',
    );
    _copyIndex = TextEditingController(
      text: existing?.type == MethodType.addSet
          ? existing?.params['copyFromSetIndex']?.toString() ?? '-1'
          : '-1',
    );
    _type = existing?.type ?? MethodType.weight;
    _sign = existing?.params['sign'] as String? ?? '+';
    _addMode = existing?.params.containsKey('copyFromSetIndex') == true
        ? AddSetMode.copy
        : AddSetMode.explicit;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _factor,
      _amount,
      _weight,
      _reps,
      _copyIndex,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  FlowMethodDraft _draft() => FlowMethodDraft.fromEditor(
    name: _name.text,
    type: _type,
    sign: _sign,
    factorText: _factor.text,
    amountText: _amount.text,
    weightText: _weight.text,
    repsText: _reps.text,
    copyExistingSet: _addMode == AddSetMode.copy,
    copyIndexText: _copyIndex.text,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final fieldGap = expressive ? 8.0 : 12.0;
    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TonosField(controller: _name, labelText: strings.commonName),
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
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(flowMethodTypeLabel(type, strings)),
                  ),
                )
                .toList(),
          ),
        ),
        if (_type == MethodType.weight || _type == MethodType.rep) ...[
          SizedBox(height: fieldGap),
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
            controller: _type == MethodType.weight ? _factor : _amount,
            keyboardType: _type == MethodType.weight
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            labelText: _type == MethodType.weight
                ? strings.flowFactor
                : strings.flowAmount,
          ),
        ] else if (_type == MethodType.addSet) ...[
          SizedBox(height: fieldGap),
          buildRuleAddSetModeOptions(
            context,
            selected: _addMode,
            onChanged: (value) => setState(() => _addMode = value),
          ),
          const SizedBox(height: 8),
          if (_addMode == AddSetMode.explicit) ...[
            TonosField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              labelText: strings.flowWeight,
            ),
            const SizedBox(height: 8),
            TonosField(
              controller: _reps,
              keyboardType: TextInputType.number,
              labelText: strings.flowReps,
            ),
          ] else
            TonosField(
              controller: _copyIndex,
              keyboardType: TextInputType.number,
              labelText: strings.rulesCopyIndex,
            ),
        ] else if (_type == MethodType.delSet) ...[
          SizedBox(height: fieldGap),
          Text(strings.rulesDeleteLastSetBody),
        ],
      ],
    );
    return TonosDialogFrame(
      styleFormControls: true,
      child: AlertDialog(
        scrollable: expressive,
        title: Text(widget.title),
        content: expressive
            ? formContent
            : SingleChildScrollView(child: formContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _draft()),
            child: Text(strings.commonSave),
          ),
        ],
      ),
    );
  }
}
