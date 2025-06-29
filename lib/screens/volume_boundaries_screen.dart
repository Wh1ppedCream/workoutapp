import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';
import '../models/models.dart';

class VolumeBoundariesScreen extends StatefulWidget {
  const VolumeBoundariesScreen({super.key});

  @override
  State<VolumeBoundariesScreen> createState() => _VolumeBoundariesScreenState();
}

class _VolumeBoundariesScreenState extends State<VolumeBoundariesScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AppRepository();
  late TabController _tabCtrl;

  List<BodyPart> _bps = [];
  List<Muscle>   _ms  = [];
  BodyPart? _selBp;
  Muscle?   _selM;

  final _bpCtrls = List.generate(4, (_) => TextEditingController());
  final _mCtrls  = List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final bps = await _repo.fetchAllBodyPartsFull();
    final ms  = await _repo.fetchAllMusclesFull();
    setState(() {
      _bps = bps;
      _ms  = ms;
      _selBp = bps.isNotEmpty ? bps.first : null;
      _selM  = ms.isNotEmpty  ? ms.first  : null;
    });
    if (_selBp != null) _loadBpBounds(_selBp!.id);
    if (_selM  != null) _loadMBounds(_selM!.id);
  }

  Future<void> _loadBpBounds(int id) async {
    final vb = await _repo.fetchBodyPartVolumeBounds(id);
    if (vb != null) {
      setState(() {
        _bpCtrls[0].text = vb.maintenance.toString();
        _bpCtrls[1].text = vb.minEffective.toString();
        _bpCtrls[2].text = vb.maxAdaptive.toString();
        _bpCtrls[3].text = vb.maxRecoverable.toString();
      });
    }
  }

  Future<void> _loadMBounds(int id) async {
    final vb = await _repo.fetchMuscleVolumeBounds(id);
    if (vb != null) {
      setState(() {
        _mCtrls[0].text = vb.maintenance.toString();
        _mCtrls[1].text = vb.minEffective.toString();
        _mCtrls[2].text = vb.maxAdaptive.toString();
        _mCtrls[3].text = vb.maxRecoverable.toString();
      });
    }
  }

  Future<void> _saveBp() async {
    final b = VolumeBoundaries(   
      id:              _selBp!.id,
      maintenance:    double.parse(_bpCtrls[0].text),
      minEffective:   double.parse(_bpCtrls[1].text),
      maxAdaptive:    double.parse(_bpCtrls[2].text),
      maxRecoverable: double.parse(_bpCtrls[3].text),
    );
    await _repo.setBodyPartVolumeBounds(_selBp!.id, b);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _saveM() async {
    final b = VolumeBoundaries(
      id:              _selM!.id,
      maintenance:    double.parse(_mCtrls[0].text),
      minEffective:   double.parse(_mCtrls[1].text),
      maxAdaptive:    double.parse(_mCtrls[2].text),
      maxRecoverable: double.parse(_mCtrls[3].text),
    );
    await _repo.setMuscleVolumeBounds(_selM!.id, b);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Widget _boundsForm(List<TextEditingController> ctrls, VoidCallback onSave) {
    final labels = ['Maintenance', 'Min Effective', 'Max Adaptive', 'Max Recoverable'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
            TextFormField(
              controller: ctrls[i],
              decoration: InputDecoration(labelText: labels[i]),
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onSave, child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volume Boundaries'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'BodyPart'),
            Tab(text: 'Muscle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // BodyPart tab
          Column(
            children: [
              if (_bps.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<BodyPart>(
                    isExpanded: true,
                    value: _selBp,
                    items: _bps.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                    onChanged: (b) {
                      if (b == null) return;
                      setState(() => _selBp = b);
                      _loadBpBounds(b.id);
                    },
                  ),
                ),
              Expanded(child: _boundsForm(_bpCtrls, _saveBp)),
            ],
          ),
          // Muscle tab
          Column(
            children: [
              if (_ms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<Muscle>(
                    isExpanded: true,
                    value: _selM,
                    items: _ms.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                    onChanged: (m) {
                      if (m == null) return;
                      setState(() => _selM = m);
                      _loadMBounds(m.id);
                    },
                  ),
                ),
              Expanded(child: _boundsForm(_mCtrls, _saveM)),
            ],
          ),
        ],
      ),
    );
  }
}
