// File: lib/screens/analytics_dashboard_screen.dart
// for muscle and bodypart counts in the last 7 days.

import 'package:flutter/material.dart';
import '../repositories/app_repository.dart';

/// Simple pair of a name and an integer count.
class _ItemCount {
  final String name;
  final int count;
  _ItemCount(this.name, this.count);
}

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _repo = AppRepository();

  bool _isLoading = true;
  String? _error;

  List<_ItemCount> _muscleCounts = [];
  List<_ItemCount> _bodyPartCounts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // 1) Fetch muscle‐level totals (muscleId → double)
      final muscleMap = await _repo.fetchSetsPerMuscle(
        start: weekAgo,
        end: now,
      );

      // 2) Fetch body‐part totals (BodyPart → double)
      final bodyMap = await _repo.fetchSetsPerBodyPart(
        start: weekAgo,
        end: now,
      );

      // 3) Build muscleId→name map
      final muscles = await _repo.fetchAllMusclesFull();
      final muscleNames = {for (var m in muscles) m.id: m.name};

      // 4) Convert & filter muscle list
      final mList = muscleMap.entries
          .map((e) {
            final name = muscleNames[e.key] ?? 'Unknown';
            return _ItemCount(name, e.value.floor());
          })
          .where((ic) => ic.count > 0)
          .toList();
      mList.sort((a, b) => b.count.compareTo(a.count));

      // 5) Convert & filter body‐part list
      final bList = bodyMap.entries
          .map((e) => _ItemCount(e.key.name, e.value.floor()))
          .where((ic) => ic.count > 0)
          .toList();
      bList.sort((a, b) => b.count.compareTo(a.count));

      if (!mounted) return;
      setState(() {
        _muscleCounts = mList;
        _bodyPartCounts = bList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sets in Last 7 Days'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Muscle'),
            Tab(text: 'By BodyPart'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Error: $_error'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // --- By Muscle ---
                    _muscleCounts.isEmpty
                        ? const Center(child: Text('No muscle sets'))
                        : ListView.builder(
                            itemCount: _muscleCounts.length,
                            itemBuilder: (ctx, i) {
                              final ic = _muscleCounts[i];
                              return ListTile(
                                title: Text(ic.name),
                                trailing: Text(
                                  ic.count.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),

                    // --- By BodyPart ---
                    _bodyPartCounts.isEmpty
                        ? const Center(child: Text('No bodypart sets'))
                        : ListView.builder(
                            itemCount: _bodyPartCounts.length,
                            itemBuilder: (ctx, i) {
                              final ic = _bodyPartCounts[i];
                              return ListTile(
                                title: Text(ic.name),
                                trailing: Text(
                                  ic.count.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                  ],
                )),
    );
  }
}
