// File: lib/screens/volume_boundaries_screen.dart

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
  late final TabController _tabCtrl;

  // lookups
  List<BodyPart> _bps = [];
  List<Muscle> _ms = [];
  bool _isLoadingLookups = true;
  String? _lookupError;

  // selected
  BodyPart? _selBp;
  Muscle? _selM;

  // text controllers
  final _bpCtrls = List.generate(4, (_) => TextEditingController());
  final _mCtrls = List.generate(4, (_) => TextEditingController());

  // loading states for each detail panel
  bool _isLoadingBp = false;
  bool _isLoadingM = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLookups();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (var c in _bpCtrls) {
      c.dispose();
    }
    for (var c in _mCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final bps = await _repo.fetchAllBodyPartsFull();
      final ms = await _repo.fetchAllMusclesFull();
      if (!mounted) return;
      setState(() {
        _bps = bps;
        _ms = ms;
        _selBp = bps.isNotEmpty ? bps.first : null;
        _selM = ms.isNotEmpty ? ms.first : null;
        _lookupError = null;
      });
      if (_selBp != null) await _loadBpBounds(_selBp!.id);
      if (_selM != null) await _loadMBounds(_selM!.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lookupError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingLookups = false;
      });
    }
  }

  Future<void> _loadBpBounds(int id) async {
    setState(() {
      _isLoadingBp = true;
      // clear controllers while loading
      for (var c in _bpCtrls) {
        c.clear();
      }
    });
    try {
      final vb = await _repo.fetchBodyPartVolumeBounds(id);
      if (!mounted) return;
      if (vb != null) {
        setState(() {
          _bpCtrls[0].text = vb.maintenance.toString();
          _bpCtrls[1].text = vb.minEffective.toString();
          _bpCtrls[2].text = vb.maxAdaptive.toString();
          _bpCtrls[3].text = vb.maxRecoverable.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bodypart bounds: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingBp = false;
      });
    }
  }

  Future<void> _loadMBounds(int id) async {
    setState(() {
      _isLoadingM = true;
      for (var c in _mCtrls) {
        c.clear();
      }
    });
    try {
      final vb = await _repo.fetchMuscleVolumeBounds(id);
      if (!mounted) return;
      if (vb != null) {
        setState(() {
          _mCtrls[0].text = vb.maintenance.toString();
          _mCtrls[1].text = vb.minEffective.toString();
          _mCtrls[2].text = vb.maxAdaptive.toString();
          _mCtrls[3].text = vb.maxRecoverable.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load muscle bounds: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingM = false;
      });
    }
  }

  Future<void> _saveBp() async {
    if (_selBp == null) return;
    double? parse(String txt) {
      try {
        return double.parse(txt);
      } catch (_) {
        return null;
      }
    }

    final vals = _bpCtrls.map((c) => parse(c.text)).toList();
    if (vals.any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }
    final b = VolumeBoundaries(
      id: _selBp!.id,
      maintenance: vals[0]!,
      minEffective: vals[1]!,
      maxAdaptive: vals[2]!,
      maxRecoverable: vals[3]!,
    );

    try {
      await _repo.setBodyPartVolumeBounds(_selBp!.id, b);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('BodyPart bounds saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Future<void> _saveM() async {
    if (_selM == null) return;
    double? parse(String txt) {
      try {
        return double.parse(txt);
      } catch (_) {
        return null;
      }
    }

    final vals = _mCtrls.map((c) => parse(c.text)).toList();
    if (vals.any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }
    final b = VolumeBoundaries(
      id: _selM!.id,
      maintenance: vals[0]!,
      minEffective: vals[1]!,
      maxAdaptive: vals[2]!,
      maxRecoverable: vals[3]!,
    );

    try {
      await _repo.setMuscleVolumeBounds(_selM!.id, b);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Muscle bounds saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Widget _boundsForm(
          List<TextEditingController> ctrls, bool isLoading, VoidCallback onSave) =>
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < ctrls.length; i++)
                    TextFormField(
                      controller: ctrls[i],
                      decoration: InputDecoration(
                          labelText: [
                        'Maintenance',
                        'Min Effective',
                        'Max Adaptive',
                        'Max Recoverable'
                      ][i]),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onSave, child: const Text('Save')),
                ],
              ),
            );

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
      body: _isLoadingLookups
          ? const Center(child: CircularProgressIndicator())
          : (_lookupError != null)
              ? Center(child: Text('Error: $_lookupError'))
              : TabBarView(
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
                              items: _bps
                                  .map((b) => DropdownMenuItem(
                                      value: b, child: Text(b.name)))
                                  .toList(),
                              onChanged: (b) {
                                if (b == null) return;
                                setState(() => _selBp = b);
                                _loadBpBounds(b.id);
                              },
                            ),
                          ),
                        Expanded(
                            child: _boundsForm(
                                _bpCtrls, _isLoadingBp, _saveBp)),
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
                              items: _ms
                                  .map((m) => DropdownMenuItem(
                                      value: m, child: Text(m.name)))
                                  .toList(),
                              onChanged: (m) {
                                if (m == null) return;
                                setState(() => _selM = m);
                                _loadMBounds(m.id);
                              },
                            ),
                          ),
                        Expanded(
                            child:
                                _boundsForm(_mCtrls, _isLoadingM, _saveM)),
                      ],
                    ),
                  ],
                ),
    );
  }
}
