// File: lib/screens/exercise/auto_preset_flow_screen.dart

import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/preset_models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/flow_screen_widgets.dart';

import '../../theme/theme_extensions.dart';
import '../../theme/flow_diagram_presentation.dart';
import '../../theme/expressive_planning_tokens.dart';
import '../../theme/widgets/tonos_dialog.dart';
import '../../theme/widgets/tonos_field.dart';
import 'flow_editor_expressive_widgets.dart';

enum AddSetMode { explicit, copy }

String _methodTypeLabel(MethodType type, AppLocalizations strings) {
  return switch (type) {
    MethodType.weight => strings.flowMethodWeight,
    MethodType.rep => strings.flowMethodReps,
    MethodType.addSet => strings.flowMethodAddSet,
    MethodType.delSet => strings.flowMethodDeleteSet,
  };
}

/// The persisted location for a progression flow and its reusable actions.
enum FlowProgressionScope { plan, appDefault, profileDefault }

/// Lets the same progression editor work with a plan, app defaults, or a
/// gym-profile default without duplicating the graph editing experience.
class FlowProgressionTarget {
  final FlowProgressionScope scope;
  final int? presetId;
  final int? profileId;
  final String? profileName;

  const FlowProgressionTarget._({
    required this.scope,
    this.presetId,
    this.profileId,
    this.profileName,
  });

  FlowProgressionTarget.plan({required int presetId})
    : this._(scope: FlowProgressionScope.plan, presetId: presetId);

  const FlowProgressionTarget.appDefaults()
    : this._(scope: FlowProgressionScope.appDefault);

  FlowProgressionTarget.profileDefaults({
    required int profileId,
    required String profileName,
  }) : this._(
         scope: FlowProgressionScope.profileDefault,
         profileId: profileId,
         profileName: profileName,
       );

  String titleFor(AppLocalizations strings) => switch (scope) {
    FlowProgressionScope.plan => strings.planProgression,
    FlowProgressionScope.appDefault => strings.flowAppDefaultTitle,
    FlowProgressionScope.profileDefault => strings.flowProfileDefaultTitle,
  };

  String subtitleFor(AppLocalizations strings) => switch (scope) {
    FlowProgressionScope.plan => strings.flowPlanSubtitle,
    FlowProgressionScope.appDefault => strings.flowAppDefaultSubtitle,
    FlowProgressionScope.profileDefault => strings.flowProfileDefaultSubtitle(
      profileName ?? strings.flowThisGymProfile,
    ),
  };

  Future<FlowDefinition> fetchDefinition(AppRepository repository) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.fetchFlowDefinition(presetId!),
      FlowProgressionScope.appDefault => repository.fetchDefaultFlowDefinition(
        'app',
      ),
      FlowProgressionScope.profileDefault =>
        repository.fetchDefaultFlowDefinition('profile', profileId: profileId),
    };
  }

  Future<List<FlowMethod>> fetchMethods(AppRepository repository) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.fetchFlowMethods(presetId!),
      FlowProgressionScope.appDefault => repository.fetchDefaultFlowMethods(
        'app',
      ),
      FlowProgressionScope.profileDefault => repository.fetchDefaultFlowMethods(
        'profile',
        profileId: profileId,
      ),
    };
  }

  Future<void> saveDefinition(
    AppRepository repository,
    FlowDefinition definition,
  ) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.upsertFlowDefinition(
        presetId!,
        definition,
      ),
      FlowProgressionScope.appDefault => repository.upsertDefaultFlow(
        'app',
        flowJson: definition.toJson(),
      ),
      FlowProgressionScope.profileDefault => repository.upsertDefaultFlow(
        'profile',
        profileId: profileId,
        flowJson: definition.toJson(),
      ),
    };
  }

  Future<FlowMethod> addMethod(
    AppRepository repository, {
    required String name,
    required MethodType type,
    required Map<String, dynamic> params,
  }) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.upsertFlowMethod(
        presetId: presetId!,
        name: name,
        type: type,
        params: params,
      ),
      FlowProgressionScope.appDefault => repository.upsertDefaultFlowMethod(
        scope: 'app',
        name: name,
        type: type,
        params: params,
      ),
      FlowProgressionScope.profileDefault => repository.upsertDefaultFlowMethod(
        scope: 'profile',
        profileId: profileId,
        name: name,
        type: type,
        params: params,
      ),
    };
  }

  Future<void> deleteMethod(AppRepository repository, FlowMethod method) {
    return switch (scope) {
      FlowProgressionScope.plan => repository.deleteFlowMethodAndReferences(
        method,
      ),
      FlowProgressionScope.appDefault =>
        repository.deleteDefaultFlowMethodAndReferences(
          scope: 'app',
          name: method.name,
        ),
      FlowProgressionScope.profileDefault =>
        repository.deleteDefaultFlowMethodAndReferences(
          scope: 'profile',
          profileId: profileId,
          name: method.name,
        ),
    };
  }
}

/// Screen to edit the automatic‐preset flowchart for a given preset.
class AutoPresetFlowScreen extends StatefulWidget {
  final FlowProgressionTarget target;

  AutoPresetFlowScreen({super.key, required int presetId})
    : target = FlowProgressionTarget.plan(presetId: presetId);

  const AutoPresetFlowScreen.appDefaults({super.key})
    : target = const FlowProgressionTarget.appDefaults();

  AutoPresetFlowScreen.profileDefaults({
    super.key,
    required int profileId,
    required String profileName,
  }) : target = FlowProgressionTarget.profileDefaults(
         profileId: profileId,
         profileName: profileName,
       );

  @override
  State<AutoPresetFlowScreen> createState() => _AutoPresetFlowScreenState();
}

class _AutoPresetFlowScreenState extends State<AutoPresetFlowScreen> {
  AppRepository get _repo => context.read<AppRepository>();

  late Dashboard _dashboard;
  final Map<String, FlowElement> _nodes = {};
  final Map<String, _NodeData> _nodeData = {};
  final Map<int, int> _placement = {}; // depth → count in that row

  int _successCounter = 0;
  int _failureCounter = 0;

  List<FlowEdge> _edges = [];
  FlowDefinition? _flowDef;
  List<FlowMethod> _methods = [];

  FlowMethod? _selectedMethod;
  String? _selectedBranchParent;
  String? _selectedMethodNode;
  String? _selectedGraphNode;
  bool _needsInitialFit = false;

  static const double _canvasLeftInset = 24;

  bool get _usesExpressive =>
      AppExpressivePlanningTokens.maybeOf(context) != null;

  FlowEditorGraphMetrics get _graphMetrics =>
      flowEditorGraphMetrics(expressive: _usesExpressive);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flow = context.flowTokens;
    final dataVisualization = context.dataVisualizationTokens;

    final bg = flow.canvas;
    final grid = flowEditorGridColor(context, dataVisualization.grid);

    final root = _nodes['1st attempt'];
    if (root != null) {
      updateFlowDiagramPresentation(
        nodes: _nodes.values,
        rootId: root.id,
        success: flow.success,
        failure: flow.failure,
        loopback: flow.loopback,
        background: flow.nodeBackground,
        border: flow.nodeBorder,
        text: flow.nodeText,
      );
      _applyNodeSelectionPresentation();
    }

    _dashboard.setGridBackgroundParams(
      GridBackgroundParams(backgroundColor: bg, gridColor: grid),
    );
  }

  @override
  void initState() {
    super.initState();
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);
    _loadAll();
  }

  Future<void> _loadAll() async {
    final definitionFuture = widget.target.fetchDefinition(_repo);
    final methodsFuture = widget.target.fetchMethods(_repo);
    final def = await definitionFuture;
    final methods = await methodsFuture;
    if (!mounted) return;
    setState(() {
      _flowDef = def;
      _methods = methods;
      _edges = def.edges.toList();
      _selectedMethod = null;
      _selectedBranchParent = null;
      _selectedMethodNode = null;
      _selectedGraphNode = null;
      _successCounter = 0;
      _failureCounter = 0;
    });
    _buildDashboard();
    _initializeCounters();
  }

  void _initializeCounters() {
    final succRe = RegExp(r'^success(\d+)$');
    final failRe = RegExp(r'^fail(\d+)$');
    final succNums = <int>[];
    final failNums = <int>[];

    for (final name in _nodes.keys) {
      final ms = succRe.firstMatch(name);
      if (ms != null) succNums.add(int.tryParse(ms.group(1)!) ?? 0);
      final mf = failRe.firstMatch(name);
      if (mf != null) failNums.add(int.tryParse(mf.group(1)!) ?? 0);
    }

    _successCounter = succNums.isEmpty ? 0 : succNums.reduce(max);
    _failureCounter = failNums.isEmpty ? 0 : failNums.reduce(max);
  }

  void _buildDashboard() {
    final flow = context.flowTokens;
    final dataVisualization = context.dataVisualizationTokens;
    final metrics = _graphMetrics;
    _needsInitialFit = true;

    // 1) Create dashboard
    _dashboard = Dashboard(defaultArrowStyle: ArrowStyle.curve);

    // 2) Re-set your grid colors on the fresh dashboard
    _dashboard.setGridBackgroundParams(
      GridBackgroundParams(
        backgroundColor: flow.canvas,
        gridColor: flowEditorGridColor(context, dataVisualization.grid),
      ),
    );
    _nodes.clear();
    _nodeData.clear();
    _placement.clear();

    final savedNodes = _flowDef?.nodes.toSet() ?? const <String>{};
    if (!savedNodes.contains('1st attempt')) {
      // Recover safely from an empty or malformed legacy definition.
      _edges = [];
      _initializeDefaultTree();
    } else {
      _edges = _edges.where((edge) {
        if (edge.outcome == 'method') {
          return savedNodes.contains(edge.from);
        }
        return (edge.outcome == 'success' || edge.outcome == 'failure') &&
            savedNodes.contains(edge.from) &&
            savedNodes.contains(edge.to);
      }).toList();

      // BFS to compute depths
      final depths = {'1st attempt': 0};
      final queue = ['1st attempt'];
      var queueIndex = 0;
      final adj = <String, List<String>>{};
      for (final e in _edges.where((e) => e.outcome != 'method')) {
        adj.putIfAbsent(e.from, () => []).add(e.to);
      }
      while (queueIndex < queue.length) {
        final cur = queue[queueIndex++];
        final d = depths[cur]!;
        for (var nb in adj[cur] ?? []) {
          if (!depths.containsKey(nb)) {
            depths[nb] = d + 1;
            queue.add(nb);
          }
        }
      }

      final reachableNodes = depths.keys.toSet();
      _edges = _edges.where((edge) {
        if (!reachableNodes.contains(edge.from)) return false;
        return edge.outcome == 'method' || reachableNodes.contains(edge.to);
      }).toList();

      // create nodes
      final sorted = depths.keys.toList()
        ..sort((a, b) => depths[a]!.compareTo(depths[b]!));
      for (var name in sorted) {
        final depth = depths[name]!;
        final idx = (_placement[depth] ?? 0);
        _placement[depth] = idx + 1;
        final pos =
            metrics.rootCenter +
            Offset(
              idx * metrics.horizontalSpacing,
              depth * metrics.verticalSpacing,
            );

        final el = FlowElement(
          position: pos,
          size: metrics.nodeSize,
          text: name,
          backgroundColor: flow.nodeBackground,
          borderColor: flow.nodeBorder,
          textColor: flow.nodeText,
          textSize: metrics.textSize,
          textIsBold: metrics.expressive,
          borderThickness: metrics.expressive ? 2 : 3,
          kind: ElementKind.rectangle,
          handlers: const [
            Handler.bottomCenter,
            Handler.topCenter,
            Handler.leftCenter,
            Handler.rightCenter,
          ],
        );
        _dashboard.addElement(el);
        _nodes[name] = el;
        _nodeData[name] = _NodeData(depth: depth, baseCenter: pos);
      }

      // branch edges
      for (var e in _edges.where((e) => e.outcome != 'method')) {
        final fromEl = _nodes[e.from];
        final toEl = _nodes[e.to];
        if (fromEl == null || toEl == null) continue;
        final isSucc = e.outcome == 'success';

        // grab your colors once per loop

        _dashboard.addNextById(
          fromEl,
          toEl.id,
          ArrowParams(
            color: isSucc ? flow.success : flow.failure,
            thickness: 2,
            style: isSucc ? ArrowStyle.segmented : ArrowStyle.curve,
            startArrowPosition: Alignment.bottomCenter,
            endArrowPosition: Alignment.topCenter,
          ),
        );
      }
    }

    // method bullets
    for (var node in _nodes.keys) {
      _refreshNodeText(node);
    }

    if (_nodes.containsKey('1st attempt')) {
      _applyLoopbacks();
    }
    _applyNodeSelectionPresentation();
  }

  void _initializeDefaultTree() {
    final flow = context.flowTokens;
    final metrics = _graphMetrics;
    final root = FlowElement(
      position: metrics.rootCenter,
      size: metrics.nodeSize,
      text: '1st attempt',
      backgroundColor: flow.nodeBackground,
      borderColor: flow.nodeBorder,
      textColor: flow.nodeText,
      textSize: metrics.textSize,
      textIsBold: metrics.expressive,
      borderThickness: metrics.expressive ? 2 : 3,
      kind: ElementKind.rectangle,
      handlers: const [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    _dashboard.addElement(root);
    _nodes[root.text] = root;
    _nodeData[root.text] = _NodeData(depth: 0, baseCenter: metrics.rootCenter);
    _placement[0] = 1;

    final sName = 'success${++_successCounter}';
    _createBranchNode('1st attempt', sName, 'success');
    final fName = 'fail${++_failureCounter}';
    _createBranchNode('1st attempt', fName, 'failure');
  }

  // ─── Helper methods ───────────────────────────────────────

  void _refreshNodeText(String nodeName) {
    final methods = _edges
        .where((e) => e.from == nodeName && e.outcome == 'method')
        .map((e) => e.to)
        .toList();

    final el = _nodes[nodeName]!;
    el.setText([nodeName, ...methods].join('\n'));
    final metrics = _graphMetrics;
    final zoom = metrics.expressive ? _dashboard.zoomFactor : 1.0;
    el.changeSize(
      Size(
        metrics.nodeSize.width * zoom,
        flowEditorNodeHeight(nodeName, methods, metrics) * zoom,
      ),
    );
  }

  void _applyNodeSelectionPresentation() {
    final flow = context.flowTokens;
    final metrics = _graphMetrics;
    for (final entry in _nodes.entries) {
      final selected = metrics.expressive && entry.key == _selectedGraphNode;
      entry.value
        ..setBackgroundColor(flow.nodeBackground)
        ..setBorderColor(selected ? flow.action : flow.nodeBorder)
        ..setBorderThickness(selected ? 3.5 : (metrics.expressive ? 2 : 3))
        ..setTextColor(flow.nodeText)
        ..setTextIsBold(metrics.expressive);
    }
  }

  void _onGraphElementPressed(FlowElement element) {
    if (!_usesExpressive) return;
    String? name;
    for (final entry in _nodes.entries) {
      if (identical(entry.value, element)) {
        name = entry.key;
        break;
      }
    }
    if (name == null) return;

    final hasTwoBranches =
        _edges
            .where(
              (edge) => edge.outcome == 'success' || edge.outcome == 'failure',
            )
            .where((edge) => edge.from == name)
            .length >=
        2;
    setState(() {
      _selectedGraphNode = name;
      _selectedBranchParent = hasTwoBranches ? null : name;
      _selectedMethodNode = name == '1st attempt' ? null : name;
      _selectedMethod = null;
      _applyNodeSelectionPresentation();
    });
  }

  void _fitDashboard(Size viewport) => fitFlowDashboardToViewport(
    _dashboard,
    viewport,
    includeCurveBounds: _usesExpressive,
  );

  void _applyLoopbacks() {
    final loopback = context.flowTokens.loopback;
    final rootEl = _nodes['1st attempt'];
    if (rootEl == null) return;
    final hasSucc = <String, bool>{};
    final hasFail = <String, bool>{};
    for (var e in _edges) {
      if (e.outcome == 'success') hasSucc[e.from] = true;
      if (e.outcome == 'failure') hasFail[e.from] = true;
    }
    for (var name in _nodes.keys) {
      if (name == '1st attempt') continue;
      final fromEl = _nodes[name]!;
      if (hasSucc[name] != true) {
        _dashboard.addNextById(
          fromEl,
          rootEl.id,
          ArrowParams(
            color: loopback,
            thickness: 2,
            style: ArrowStyle.curve,
            startArrowPosition: Alignment.centerLeft,
            endArrowPosition: Alignment.centerLeft,
          ),
        );
      }
      if (hasFail[name] != true) {
        _dashboard.addNextById(
          fromEl,
          rootEl.id,
          ArrowParams(
            color: loopback,
            thickness: 2,
            style: ArrowStyle.curve,
            startArrowPosition: Alignment.centerLeft,
            endArrowPosition: Alignment.centerLeft,
          ),
        );
      }
    }
  }

  void _createBranchNode(String parent, String name, String outcome) {
    final flow = context.flowTokens;
    final metrics = _graphMetrics;
    final loopback = flow.loopback;
    final pData = _nodeData[parent]!;
    final depth = pData.depth + 1;
    final idx = (_placement[depth] ?? 0);
    _placement[depth] = idx + 1;

    final basePosition =
        metrics.branchOrigin +
        Offset(
          idx * metrics.horizontalSpacing,
          depth * metrics.verticalSpacing,
        );
    final zoom = metrics.expressive ? _dashboard.zoomFactor : 1.0;
    final baseNodeSize = Size(
      metrics.nodeSize.width,
      flowEditorNodeHeight(name, const [], metrics),
    );
    final desiredCenter = metrics.expressive
        ? _nodes[parent]!.getHandlerPosition(Alignment.center) +
              (basePosition - pData.baseCenter) * zoom
        : basePosition;
    // Dashboard.addElement scales new elements from zoom 1 to its current
    // zoom. FlowElement's constructor, however, subtracts half its unscaled
    // bounds from the supplied center, so compensate for that size change.
    final position = metrics.expressive
        ? desiredCenter +
              Offset(
                (baseNodeSize.width + 15) * (1 - zoom) / 2,
                (baseNodeSize.height + 15) * (1 - zoom) / 2,
              )
        : desiredCenter;
    final el = FlowElement(
      position: position,
      size: baseNodeSize,
      handlerSize: 15,
      text: name,
      backgroundColor: flow.nodeBackground,
      borderColor: flow.nodeBorder,
      textColor: flow.nodeText,
      textSize: metrics.textSize,
      textIsBold: metrics.expressive,
      borderThickness: metrics.expressive ? 2 : 3,
      kind: ElementKind.rectangle,
      handlers: const [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    _dashboard.addElement(el);
    _nodes[name] = el;
    _nodeData[name] = _NodeData(depth: depth, baseCenter: basePosition);

    final branchColor = outcome == 'success' ? flow.success : flow.failure;
    final branchStyle = outcome == 'success'
        ? ArrowStyle.segmented
        : ArrowStyle.curve;
    _dashboard.addNextById(
      _nodes[parent]!,
      el.id,
      ArrowParams(
        color: branchColor,
        thickness: 2,
        style: branchStyle,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );

    _edges.add(FlowEdge(from: parent, outcome: outcome, to: name));

    // loopback
    final rootEl = _nodes['1st attempt']!;
    _dashboard.addNextById(
      el,
      rootEl.id,
      ArrowParams(
        color: loopback,
        thickness: 2,
        style: ArrowStyle.curve,
        startArrowPosition: Alignment.centerLeft,
        endArrowPosition: Alignment.centerLeft,
      ),
    );

    if (_edges.any((e) => e.from == parent && e.outcome == 'success') &&
        _edges.any((e) => e.from == parent && e.outcome == 'failure')) {
      _dashboard.removeElementConnection(_nodes[parent]!, Handler.leftCenter);
    }

    setState(() {});
  }

  Future<void> _showManageMethodsDialog() async {
    final strings = AppLocalizations.of(context);
    final expressive = _usesExpressive;
    final deleted = await showDialog<bool>(
      context: context,
      builder: (ctx) => TonosDialogFrame(
        child: AlertDialog(
          title: Text(strings.flowManageMethods),
          content: expressive
              ? FlowEditorManageActionsList(
                  methods: _methods,
                  typeLabel: (method) => _methodTypeLabel(method.type, strings),
                  onDelete: (method) async {
                    await widget.target.deleteMethod(_repo, method);
                    if (!ctx.mounted || !mounted) return;
                    Navigator.of(ctx).pop(true);
                  },
                  onAdd: () {
                    Navigator.of(ctx).pop(false);
                    _showAddMethodDialog();
                  },
                )
              : SizedBox(
                  width: 300,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (var m in _methods)
                        ListTile(
                          title: Text(
                            m.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _methodTypeLabel(m.type, strings),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: strings.commonDelete,
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final navigator = Navigator.of(ctx);
                              await widget.target.deleteMethod(_repo, m);
                              if (!ctx.mounted || !mounted) return;
                              navigator.pop();
                            },
                          ),
                        ),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: Text(strings.flowAddNewMethod),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _showAddMethodDialog();
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
    if (!mounted) return;
    if (!expressive) {
      await _loadAll();
      return;
    }
    if (deleted != true) return;

    final methods = await widget.target.fetchMethods(_repo);
    if (!mounted) return;
    final remainingNames = methods.map((method) => method.name).toSet();
    final changedNodes = _edges
        .where(
          (edge) =>
              edge.outcome == 'method' && !remainingNames.contains(edge.to),
        )
        .map((edge) => edge.from)
        .toSet();
    setState(() {
      _methods = methods;
      _edges.removeWhere(
        (edge) => edge.outcome == 'method' && !remainingNames.contains(edge.to),
      );
      if (_selectedMethod != null &&
          !methods.any((method) => method.id == _selectedMethod!.id)) {
        _selectedMethod = null;
      }
      for (final node in changedNodes) {
        if (_nodes.containsKey(node)) _refreshNodeText(node);
      }
      _applyNodeSelectionPresentation();
    });
  }

  Future<void> _showAddMethodDialog() async {
    final strings = AppLocalizations.of(context);
    final nameCtl = TextEditingController();
    MethodType type = MethodType.weight;
    String sign = '+';
    final factorCtl = TextEditingController(text: '1.0');
    final amountCtl = TextEditingController(text: '0');
    AddSetMode addMode = AddSetMode.explicit;
    final weightCtl = TextEditingController(text: '0.0');
    final repsCtl = TextEditingController(text: '0');
    final copyIndexCtl = TextEditingController(text: '-1');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => TonosDialogFrame(
          styleFormControls: true,
          child: AlertDialog(
            title: Text(strings.flowNewMethod),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TonosField(
                    controller: nameCtl,
                    labelText: strings.commonName,
                  ),
                  const SizedBox(height: 12),
                  TonosDialogDropdownButton<MethodType>(
                    value: type,
                    isExpanded: true,
                    onChanged: (v) => setState(() => type = v!),
                    items: MethodType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(_methodTypeLabel(t, strings)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  if (type == MethodType.weight) ...[
                    TonosDialogDropdownButton<String>(
                      value: sign,
                      isExpanded: false,
                      onChanged: (v) => setState(() => sign = v!),
                      items: const [
                        DropdownMenuItem(value: '+', child: Text('+')),
                        DropdownMenuItem(value: '-', child: Text('-')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TonosField(
                      controller: factorCtl,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      labelText: strings.flowFactor,
                    ),
                  ] else if (type == MethodType.rep) ...[
                    TonosDialogDropdownButton<String>(
                      value: sign,
                      isExpanded: false,
                      onChanged: (v) => setState(() => sign = v!),
                      items: const [
                        DropdownMenuItem(value: '+', child: Text('+')),
                        DropdownMenuItem(value: '-', child: Text('-')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TonosField(
                      controller: amountCtl,
                      keyboardType: TextInputType.number,
                      labelText: strings.flowAmount,
                    ),
                  ] else if (type == MethodType.addSet) ...[
                    Row(
                      children: [
                        Radio<AddSetMode>(
                          value: AddSetMode.explicit,
                          groupValue: addMode,
                          onChanged: (v) => setState(() => addMode = v!),
                        ),
                        Text(strings.flowExplicit),
                        Radio<AddSetMode>(
                          value: AddSetMode.copy,
                          groupValue: addMode,
                          onChanged: (v) => setState(() => addMode = v!),
                        ),
                        Text(strings.flowCopyFromSet),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (addMode == AddSetMode.explicit)
                      TonosField(
                        controller: weightCtl,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        labelText: strings.flowWeight,
                      ),
                    if (addMode == AddSetMode.explicit)
                      const SizedBox(height: 8),
                    if (addMode == AddSetMode.explicit)
                      TonosField(
                        controller: repsCtl,
                        keyboardType: TextInputType.number,
                        labelText: strings.flowReps,
                      ),
                    if (addMode == AddSetMode.copy)
                      TonosField(
                        controller: copyIndexCtl,
                        keyboardType: TextInputType.number,
                        labelText: strings.flowSetIndex,
                      ),
                  ] else if (type == MethodType.delSet) ...[
                    Text(strings.flowDeleteLastSetBody),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(strings.commonSave),
              ),
            ],
          ),
        ),
      ),
    );

    final methodName = nameCtl.text.trim();
    final factor = double.tryParse(factorCtl.text) ?? 1.0;
    final amount = int.tryParse(amountCtl.text) ?? 0;
    final weight = double.tryParse(weightCtl.text) ?? 0.0;
    final reps = int.tryParse(repsCtl.text) ?? 0;
    final copyIndex = int.tryParse(copyIndexCtl.text) ?? -1;
    for (final controller in [
      nameCtl,
      factorCtl,
      amountCtl,
      weightCtl,
      repsCtl,
      copyIndexCtl,
    ]) {
      controller.dispose();
    }

    if (saved != true || !mounted) return;

    Map<String, dynamic> params;
    switch (type) {
      case MethodType.weight:
        params = {'sign': sign, 'factor': factor};
        break;
      case MethodType.rep:
        params = {'sign': sign, 'amount': amount};
        break;
      case MethodType.addSet:
        params = addMode == AddSetMode.explicit
            ? {'weight': weight, 'reps': reps}
            : {'copyFromSetIndex': copyIndex};
        break;
      case MethodType.delSet:
        params = {};
        break;
    }

    if (methodName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.flowMethodNameRequired)));
      return;
    }

    await widget.target.addMethod(
      _repo,
      name: methodName,
      type: type,
      params: params,
    );
    final methods = await widget.target.fetchMethods(_repo);
    if (!mounted) return;
    _methods = methods;
    setState(() {});
  }

  Future<void> _saveFlow() async {
    final def = FlowDefinition(nodes: _nodes.keys.toList(), edges: _edges);
    await widget.target.saveDefinition(_repo, def);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _onAddSuccess() {
    final parent = _selectedBranchParent;
    if (parent == null) return;
    final name = 'success${++_successCounter}';
    _createBranchNode(parent, name, 'success');
  }

  void _onAddFailure() {
    final parent = _selectedBranchParent;
    if (parent == null) return;
    final name = 'fail${++_failureCounter}';
    _createBranchNode(parent, name, 'failure');
  }

  void _onAddMethod() {
    final target = _selectedMethodNode;
    final method = _selectedMethod;
    if (target == null || method == null) return;
    _edges.add(FlowEdge(from: target, outcome: 'method', to: method.name));
    _refreshNodeText(target);
    setState(() {});
  }

  void _onRemoveMethod() {
    final target = _selectedMethodNode;
    if (target == null) return;
    final methodEdges = _edges
        .where((e) => e.from == target && e.outcome == 'method')
        .toList();
    if (methodEdges.isEmpty) return;
    _edges.remove(methodEdges.last);
    _refreshNodeText(target);
    setState(() {});
  }

  void _onRemoveNode() {
    final name = _selectedMethodNode;
    if (name == null || name == '1st attempt') return;
    final branchKids = _edges.where(
      (e) =>
          e.from == name && (e.outcome == 'success' || e.outcome == 'failure'),
    );
    if (branchKids.isNotEmpty) return;
    final hasMethods = _edges.any(
      (e) => e.from == name && e.outcome == 'method',
    );
    if (hasMethods) return;
    _edges.removeWhere(
      (e) => e.to == name && (e.outcome == 'success' || e.outcome == 'failure'),
    );
    final el = _nodes.remove(name)!;
    _dashboard.removeElement(el);
    _nodeData.remove(name);
    _selectedMethodNode = null;
    _selectedMethod = null;
    _selectedBranchParent = null;
    _selectedGraphNode = null;
    setState(_applyNodeSelectionPresentation);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    // branchable nodes
    final outCounts = <String, int>{};
    for (var e in _edges.where(
      (e) => e.outcome == 'success' || e.outcome == 'failure',
    )) {
      outCounts[e.from] = (outCounts[e.from] ?? 0) + 1;
    }
    final branchable = _nodes.keys
        .where((n) => (outCounts[n] ?? 0) < 2)
        .toList();

    final existingSuccess = _edges
        .where((e) => e.from == _selectedBranchParent && e.outcome == 'success')
        .length;
    final existingFailure = _edges
        .where((e) => e.from == _selectedBranchParent && e.outcome == 'failure')
        .length;

    final methodTargets = _nodes.keys.where((n) => n != '1st attempt').toList();
    final attachedMethods = _edges
        .where((e) => e.from == _selectedMethodNode && e.outcome == 'method')
        .map((e) => e.to)
        .toList();
    final attachedTypes = attachedMethods
        .map<MethodType?>((name) {
          final m = _methods.where((m) => m.name == name);
          return m.isEmpty ? null : m.first.type;
        })
        .whereType<MethodType>()
        .toSet();
    final availableMethods = _methods
        .where((m) => !attachedTypes.contains(m.type))
        .toList();
    final canAdd =
        _selectedMethodNode != null &&
        _selectedMethod != null &&
        availableMethods.contains(_selectedMethod);
    final canDeleteNode =
        !(_selectedMethodNode == null ||
            _selectedMethodNode == '1st attempt' ||
            _edges.any(
              (e) =>
                  e.from == _selectedMethodNode! &&
                  (e.outcome == 'success' || e.outcome == 'failure'),
            ) ||
            attachedMethods.isNotEmpty);
    final expressive = _usesExpressive;
    final hasSelectedNodeBranches = _edges.any(
      (edge) =>
          edge.from == _selectedMethodNode &&
          (edge.outcome == 'success' || edge.outcome == 'failure'),
    );
    final branchGuidance = !expressive
        ? null
        : branchable.isEmpty
        ? strings.flowBranchCompleteGuidance
        : !branchable.contains(_selectedBranchParent)
        ? strings.flowBranchSelectGuidance
        : null;
    final actionGuidance = !expressive
        ? null
        : methodTargets.isEmpty
        ? strings.flowActionCreateMethodGuidance
        : _selectedMethodNode == null
        ? strings.flowActionSelectNodeGuidance
        : _selectedMethodNode == '1st attempt'
        ? strings.flowActionRootGuidance
        : (hasSelectedNodeBranches || attachedMethods.isNotEmpty)
        ? strings.flowActionRemoveDependenciesGuidance
        : _methods.isEmpty
        ? strings.flowActionCreateMethodGuidance
        : availableMethods.isEmpty
        ? strings.flowActionTypesUsedGuidance
        : _selectedMethod == null
        ? strings.flowActionSelectMethodGuidance
        : null;

    final controlDeck = Padding(
      padding: EdgeInsets.fromLTRB(
        expressive ? 12 : 16,
        expressive ? 2 : 4,
        expressive ? 12 : 16,
        expressive ? 8 : 12,
      ),
      child: _FlowControlDeck(
        branchable: branchable,
        selectedBranchParent: _selectedBranchParent,
        onBranchParentChanged: (value) {
          setState(() {
            _selectedBranchParent = value;
            if (expressive && value != null) {
              _selectedGraphNode = value;
              _applyNodeSelectionPresentation();
            }
          });
        },
        onAddSuccess: _onAddSuccess,
        onAddFailure: _onAddFailure,
        existingSuccess: existingSuccess,
        existingFailure: existingFailure,
        methodTargets: methodTargets,
        selectedMethodNode: _selectedMethodNode,
        onMethodNodeChanged: (value) {
          setState(() {
            _selectedMethodNode = value;
            _selectedMethod = null;
            if (expressive && value != null) {
              _selectedGraphNode = value;
              _applyNodeSelectionPresentation();
            }
          });
        },
        availableMethods: availableMethods,
        selectedMethod: _selectedMethod,
        onMethodChanged: (method) => setState(() => _selectedMethod = method),
        canAddMethod: canAdd,
        onAddMethod: _onAddMethod,
        hasAttachedMethods: attachedMethods.isNotEmpty,
        onRemoveMethod: _onRemoveMethod,
        canDeleteNode: canDeleteNode,
        onRemoveNode: _onRemoveNode,
        branchGuidance: branchGuidance,
        actionGuidance: actionGuidance,
      ),
    );

    Widget graphCanvas() {
      if (!expressive) {
        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.only(left: _canvasLeftInset),
            child: FlowChartCanvas(
              dashboard: _dashboard,
              onTap: (_, __) {},
              onElementPressed: (_, __, ___) {},
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(left: _canvasLeftInset),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_needsInitialFit &&
                constraints.maxWidth.isFinite &&
                constraints.maxHeight.isFinite &&
                constraints.maxWidth > 0 &&
                constraints.maxHeight > 0) {
              _needsInitialFit = false;
              final size = constraints.biggest;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _fitDashboard(size);
              });
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: FlowChartCanvas(
                    dashboard: _dashboard,
                    onTap: (_, __) {},
                    onElementPressed: (_, __, element) =>
                        _onGraphElementPressed(element),
                  ),
                ),
                FlowEditorFitToViewButton(
                  onPressed: () => _fitDashboard(constraints.biggest),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.flowTokens.canvas,
      // Text entry is in an inset-aware dialog; keep the editor behind it stable.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            expressive
                ? ExpressiveFlowEditorHeader(
                    title: widget.target.titleFor(strings),
                    subtitle: widget.target.subtitleFor(strings),
                    onBack: () => Navigator.maybePop(context),
                    onManageActions: _showManageMethodsDialog,
                    onSave: _saveFlow,
                  )
                : _AutoFlowHeader(
                    title: widget.target.titleFor(strings),
                    subtitle: widget.target.subtitleFor(strings),
                    onBack: () => Navigator.maybePop(context),
                    onManageMethods: _showManageMethodsDialog,
                    onSave: _saveFlow,
                  ),
            Expanded(
              child: expressive
                  ? ExpressiveFlowEditorWorkspace(
                      controls: controlDeck,
                      graph: graphCanvas(),
                    )
                  : Column(
                      children: [
                        controlDeck,
                        Expanded(child: graphCanvas()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal data for positioning
class _NodeData {
  final int depth;
  final Offset baseCenter;
  _NodeData({required this.depth, required this.baseCenter});
}

class _AutoFlowHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onManageMethods;
  final VoidCallback onSave;

  const _AutoFlowHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onManageMethods,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context).commonBack,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 27,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: expressive?.onPage,
                      ),
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: expressive?.onPage ?? scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            style: expressive == null
                ? null
                : IconButton.styleFrom(
                    backgroundColor: expressive.actionSecondary,
                    foregroundColor: expressive.actionSecondaryForeground,
                  ),
            tooltip: AppLocalizations.of(context).flowManageActionsTooltip,
            onPressed: onManageMethods,
            icon: const Icon(Icons.tune_outlined),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: expressive == null
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: expressive.actionPrimary,
                    foregroundColor: expressive.actionPrimaryForeground,
                  ),
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(AppLocalizations.of(context).commonSave),
          ),
        ],
      ),
    );
  }
}

class _FlowControlDeck extends StatelessWidget {
  final List<String> branchable;
  final String? selectedBranchParent;
  final ValueChanged<String?> onBranchParentChanged;
  final VoidCallback onAddSuccess;
  final VoidCallback onAddFailure;
  final int existingSuccess;
  final int existingFailure;
  final List<String> methodTargets;
  final String? selectedMethodNode;
  final ValueChanged<String?> onMethodNodeChanged;
  final List<FlowMethod> availableMethods;
  final FlowMethod? selectedMethod;
  final ValueChanged<FlowMethod?> onMethodChanged;
  final bool canAddMethod;
  final VoidCallback onAddMethod;
  final bool hasAttachedMethods;
  final VoidCallback onRemoveMethod;
  final bool canDeleteNode;
  final VoidCallback onRemoveNode;
  final String? branchGuidance;
  final String? actionGuidance;

  const _FlowControlDeck({
    required this.branchable,
    required this.selectedBranchParent,
    required this.onBranchParentChanged,
    required this.onAddSuccess,
    required this.onAddFailure,
    required this.existingSuccess,
    required this.existingFailure,
    required this.methodTargets,
    required this.selectedMethodNode,
    required this.onMethodNodeChanged,
    required this.availableMethods,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.canAddMethod,
    required this.onAddMethod,
    required this.hasAttachedMethods,
    required this.onRemoveMethod,
    required this.canDeleteNode,
    required this.onRemoveNode,
    required this.branchGuidance,
    required this.actionGuidance,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final strings = AppLocalizations.of(context);
    final flow = context.flowTokens;
    final surfaces = context.surfaceTokens;
    final success = flow.success;
    final failure = flow.failure;
    final shapes = context.shapeTokens;
    final neo = context.usesNeoPresentation;
    final controlSurface =
        expressive?.configurationSurface ?? surfaces.settingsInput;
    final controlForeground = expressive != null
        ? expressive.configurationForeground
        : neo
        ? tonosForegroundForSurface(context, controlSurface)
        : scheme.onSurface;
    final controlSecondary = expressive != null
        ? expressive.configurationForeground
        : neo
        ? tonosSecondaryForegroundForSurface(context, controlSurface)
        : scheme.onSurfaceVariant;
    final controlOutline =
        expressive?.outline ??
        (neo
            ? tonosOutlineForSurface(context, controlSurface)
            : scheme.outline);

    InputDecoration controlDecoration({
      required String label,
      required IconData icon,
    }) {
      if (!neo && expressive == null) {
        return InputDecoration(labelText: label, prefixIcon: Icon(icon));
      }
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: controlForeground),
        filled: true,
        fillColor: controlSurface,
        labelStyle: TextStyle(color: controlSecondary),
        floatingLabelStyle: TextStyle(color: controlForeground),
        enabledBorder: OutlineInputBorder(
          borderRadius: shapes.settingsInput,
          borderSide: BorderSide(
            color: controlOutline,
            width: shapes.outlineWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: shapes.settingsInput,
          borderSide: BorderSide(
            color: context.semanticColors.focusRing,
            width: shapes.focusRingWidth,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: shapes.settingsInput,
          borderSide: BorderSide(
            color: controlOutline,
            width: shapes.outlineWidth,
          ),
        ),
      );
    }

    TextStyle? controlTextStyle() => neo || expressive != null
        ? TextStyle(color: controlForeground, fontWeight: FontWeight.w700)
        : null;

    Text menuText(String value) => Text(value, style: controlTextStyle());

    Widget branchNodeField() => expressive != null
        ? FlowEditorAnchoredChoiceField<String>(
            title: strings.flowBranchFrom,
            values: branchable,
            value: branchable.contains(selectedBranchParent)
                ? selectedBranchParent
                : null,
            label: (value) => value,
            decoration: controlDecoration(
              label: strings.flowBranchFrom,
              icon: Icons.account_tree_outlined,
            ),
            textStyle: controlTextStyle(),
            onChanged: branchable.isEmpty ? null : onBranchParentChanged,
          )
        : DropdownButtonFormField<String>(
            initialValue: branchable.contains(selectedBranchParent)
                ? selectedBranchParent
                : null,
            isExpanded: true,
            style: controlTextStyle(),
            iconEnabledColor: neo ? controlForeground : null,
            iconDisabledColor: neo
                ? controlSecondary.withValues(alpha: 0.72)
                : null,
            dropdownColor: neo ? controlSurface : null,
            borderRadius: neo ? shapes.settingsInput : null,
            decoration: controlDecoration(
              label: strings.flowBranchFrom,
              icon: Icons.account_tree_outlined,
            ),
            items: branchable
                .map(
                  (name) =>
                      DropdownMenuItem(value: name, child: menuText(name)),
                )
                .toList(),
            onChanged: onBranchParentChanged,
          );

    Widget methodNodeField() => expressive != null
        ? FlowEditorAnchoredChoiceField<String>(
            title: strings.flowApplyActionTo,
            values: methodTargets,
            value: methodTargets.contains(selectedMethodNode)
                ? selectedMethodNode
                : null,
            label: (value) => value,
            decoration: controlDecoration(
              label: strings.flowApplyActionTo,
              icon: Icons.location_on_outlined,
            ),
            textStyle: controlTextStyle(),
            onChanged: methodTargets.isEmpty ? null : onMethodNodeChanged,
          )
        : DropdownButtonFormField<String>(
            initialValue: methodTargets.contains(selectedMethodNode)
                ? selectedMethodNode
                : null,
            isExpanded: true,
            style: controlTextStyle(),
            iconEnabledColor: neo ? controlForeground : null,
            iconDisabledColor: neo
                ? controlSecondary.withValues(alpha: 0.72)
                : null,
            dropdownColor: neo ? controlSurface : null,
            borderRadius: neo ? shapes.settingsInput : null,
            decoration: controlDecoration(
              label: strings.flowApplyActionTo,
              icon: Icons.location_on_outlined,
            ),
            items: methodTargets
                .map(
                  (name) =>
                      DropdownMenuItem(value: name, child: menuText(name)),
                )
                .toList(),
            onChanged: onMethodNodeChanged,
          );

    Widget methodField() => expressive != null
        ? FlowEditorAnchoredChoiceField<FlowMethod>(
            title: strings.flowProgressionAction,
            values: availableMethods,
            value: availableMethods.contains(selectedMethod)
                ? selectedMethod
                : null,
            label: (method) => method.name,
            subtitle: (method) => _methodTypeLabel(method.type, strings),
            decoration: controlDecoration(
              label: strings.flowProgressionAction,
              icon: Icons.bolt_outlined,
            ),
            textStyle: controlTextStyle(),
            onChanged: availableMethods.isEmpty ? null : onMethodChanged,
          )
        : DropdownButtonFormField<FlowMethod>(
            initialValue: availableMethods.contains(selectedMethod)
                ? selectedMethod
                : null,
            isExpanded: true,
            style: controlTextStyle(),
            iconEnabledColor: neo ? controlForeground : null,
            iconDisabledColor: neo
                ? controlSecondary.withValues(alpha: 0.72)
                : null,
            dropdownColor: neo ? controlSurface : null,
            borderRadius: neo ? shapes.settingsInput : null,
            decoration: controlDecoration(
              label: strings.flowProgressionAction,
              icon: Icons.bolt_outlined,
            ),
            items: availableMethods
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(
                      method.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: controlTextStyle(),
                    ),
                  ),
                )
                .toList(),
            onChanged: onMethodChanged,
          );

    ButtonStyle branchButtonStyle(Color fill) {
      if (!neo) {
        return FilledButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: flow.onAction,
        );
      }
      final foreground = tonosForegroundForSurface(context, fill);
      return FilledButton.styleFrom(
        backgroundColor: fill,
        foregroundColor: foreground,
        disabledBackgroundColor: fill.withValues(alpha: 0.42),
        disabledForegroundColor: foreground.withValues(alpha: 0.72),
        side: BorderSide(color: tonosOutlineForSurface(context, fill)),
      );
    }

    final actionBackground =
        expressive?.actionPrimary ?? (neo ? surfaces.dialogChoice : null);
    final actionForeground =
        expressive?.actionPrimaryForeground ??
        (neo
            ? tonosForegroundForSurface(context, surfaces.dialogChoice)
            : null);
    final actionDisabledForeground = neo
        ? actionForeground!.withValues(alpha: 0.72)
        : null;
    final actionDisabledBackground = neo
        ? actionBackground!.withValues(alpha: 0.42)
        : null;
    final secondaryBackground =
        expressive?.configurationSurface ?? (neo ? surfaces.dialog : null);
    final secondaryForeground =
        expressive?.configurationForeground ??
        (neo ? tonosForegroundForSurface(context, surfaces.dialog) : null);
    final secondaryOutline =
        expressive?.outline ??
        (neo ? tonosOutlineForSurface(context, surfaces.dialog) : null);

    return Column(
      children: [
        _FlowControlCard(
          color: success,
          icon: Icons.account_tree_outlined,
          title: strings.flowAddBranchTitle,
          subtitle: strings.flowAddBranchSubtitle,
          child: Column(
            children: [
              branchNodeField(),
              SizedBox(height: expressive == null ? 10 : 8),
              if (branchGuidance != null && expressive != null)
                FlowEditorGuidance(
                  text: branchGuidance!,
                  foreground: expressive.planSupportForeground,
                ),
              if (branchGuidance != null && expressive != null)
                const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: branchButtonStyle(success),
                      onPressed:
                          selectedBranchParent == null || existingSuccess >= 1
                          ? null
                          : onAddSuccess,
                      icon: const Icon(Icons.trending_up, size: 18),
                      label: Text(strings.flowSuccess),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: branchButtonStyle(failure),
                      onPressed:
                          selectedBranchParent == null || existingFailure >= 1
                          ? null
                          : onAddFailure,
                      icon: const Icon(Icons.trending_down, size: 18),
                      label: Text(strings.flowMiss),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: expressive == null ? 10 : 8),
        _FlowControlCard(
          color: scheme.primary,
          icon: Icons.tune_outlined,
          title: strings.flowAttachActionTitle,
          subtitle: strings.flowAttachActionSubtitle,
          child: Column(
            children: [
              methodNodeField(),
              SizedBox(height: expressive == null ? 10 : 8),
              methodField(),
              SizedBox(height: expressive == null ? 10 : 8),
              if (actionGuidance != null && expressive != null)
                FlowEditorGuidance(
                  text: actionGuidance!,
                  foreground: expressive.configurationForeground,
                ),
              if (actionGuidance != null && expressive != null)
                const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        backgroundColor: actionBackground,
                        foregroundColor: actionForeground,
                        disabledBackgroundColor: actionDisabledBackground,
                        disabledForegroundColor: actionDisabledForeground,
                        side: neo
                            ? BorderSide(
                                color: tonosOutlineForSurface(
                                  context,
                                  surfaces.dialogChoice,
                                ),
                              )
                            : null,
                      ),
                      onPressed: canAddMethod ? onAddMethod : null,
                      child: Text(strings.flowAddAction),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        backgroundColor: secondaryBackground,
                        foregroundColor: secondaryForeground,
                        disabledBackgroundColor: neo
                            ? secondaryBackground!.withValues(alpha: 0.72)
                            : null,
                        disabledForegroundColor: neo
                            ? secondaryForeground!.withValues(alpha: 0.72)
                            : null,
                        side: neo ? BorderSide(color: secondaryOutline!) : null,
                      ),
                      onPressed: hasAttachedMethods ? onRemoveMethod : null,
                      child: Text(strings.flowRemoveAction),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: neo
                          ? OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              backgroundColor: secondaryBackground,
                              foregroundColor: flow.failure,
                              disabledBackgroundColor: secondaryBackground!
                                  .withValues(alpha: 0.72),
                              disabledForegroundColor: flow.failure.withValues(
                                alpha: 0.72,
                              ),
                              side: BorderSide(color: flow.failure),
                            )
                          : OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              foregroundColor: scheme.error,
                              side: BorderSide(
                                color: scheme.error.withValues(
                                  alpha: surfaces.flowErrorBorderOpacity,
                                ),
                              ),
                            ),
                      onPressed: canDeleteNode ? onRemoveNode : null,
                      child: Text(strings.flowRemoveNode),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowControlCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _FlowControlCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final surfaces = context.surfaceTokens;
    final neo = context.usesNeoPresentation;
    final expressive = AppExpressivePlanningTokens.maybeOf(context);
    final expressiveSurface = expressive == null
        ? null
        : color == scheme.primary
        ? expressive.configurationSurface
        : expressive.planSupportSurface;
    final expressiveShape = expressive == null
        ? null
        : flowEditorTileShape(expressive.supportShape);
    final foreground = expressive != null
        ? (color == scheme.primary
              ? expressive.configurationForeground
              : expressive.planSupportForeground)
        : neo
        ? tonosForegroundForSurface(context, surfaces.flowControl)
        : scheme.onSurface;
    final secondaryForeground = expressive != null
        ? foreground
        : neo
        ? tonosSecondaryForegroundForSurface(context, surfaces.flowControl)
        : scheme.onSurfaceVariant;

    final outlineBorder = Border.all(
      color:
          expressive?.outline ??
          color.withValues(alpha: surfaces.flowControlBorderOpacity),
    );
    final supportRadius = expressive?.supportShape ?? shapes.flowControl;
    final expressiveOutlineShape = expressiveShape is RoundedRectangleBorder
        ? expressiveShape.copyWith(side: outlineBorder.top)
        : null;

    final card = Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: expressiveSurface ?? surfaces.flowControl,
        borderRadius: supportRadius,
        // ExpansionTile paints an opaque Material over its parent. Keep the
        // legacy outline here, but paint the Expressive outline above the tile.
        border: expressive == null ? outlineBorder : null,
      ),
      child: ExpansionTile(
        key: PageStorageKey(title),
        shape: expressiveShape,
        collapsedShape: expressiveShape,
        tilePadding: EdgeInsets.symmetric(
          horizontal: expressive == null ? 14 : 12,
          vertical: expressive == null ? 2 : 0,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          expressive == null ? 14 : 12,
          0,
          expressive == null ? 14 : 12,
          expressive == null ? 14 : 10,
        ),
        collapsedBackgroundColor:
            expressiveSurface ??
            color.withValues(alpha: surfaces.flowControlCollapsedOpacity),
        backgroundColor:
            expressiveSurface ??
            color.withValues(alpha: surfaces.flowControlExpandedOpacity),
        textColor: neo ? foreground : null,
        collapsedTextColor: neo ? foreground : null,
        iconColor: neo ? foreground : null,
        collapsedIconColor: neo ? foreground : null,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: surfaces.flowControlIconOpacity),
            borderRadius: shapes.flowIcon,
          ),
          child: Icon(icon, color: neo ? foreground : color, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: neo ? foreground : null,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: expressive == null ? 1 : 2,
          overflow: expressive == null ? TextOverflow.ellipsis : null,
          style: theme.textTheme.bodySmall?.copyWith(
            color: secondaryForeground,
          ),
        ),
        children: [child],
      ),
    );

    if (expressive == null || expressiveOutlineShape == null) return card;

    return CustomPaint(
      foregroundPainter: FlowControlOutlinePainter(expressiveOutlineShape),
      child: card,
    );
  }
}

class FlowControlOutlinePainter extends CustomPainter {
  const FlowControlOutlinePainter(this.shape);

  final ShapeBorder shape;

  @override
  void paint(Canvas canvas, Size size) =>
      shape.paint(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(covariant FlowControlOutlinePainter oldDelegate) =>
      oldDelegate.shape != shape;
}
