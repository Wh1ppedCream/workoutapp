// File: lib/screens/nutrition/measured_items_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/health_trends_section.dart';
import '../new_measurement_item_page.dart';

class MeasuredItemsPage extends StatefulWidget {
  const MeasuredItemsPage({super.key});

  @override
  State<MeasuredItemsPage> createState() => _MeasuredItemsPageState();
}

class _MeasuredItemsPageState extends State<MeasuredItemsPage> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<List<MeasurementDefinition>> _defsFuture;

  @override
  void initState() {
    super.initState();
    _defsFuture = _loadDefinitions();
  }

  Future<List<MeasurementDefinition>> _loadDefinitions() async {
    await _repo.ensureDefaultMeasurementDefinitions();
    return _repo.fetchClassMeasurementDefinitions();
  }

  void _reloadDefinitions() {
    setState(() {
      _defsFuture = _loadDefinitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.nutritionMeasuredItems)),
      body: FutureBuilder<List<MeasurementDefinition>>(
        future: _defsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final defs = snapshot.data ?? const <MeasurementDefinition>[];

          return ListView(
            children: [
              for (final def in defs)
                ListTile(
                  title: Text(_measurementLabel(strings, def)),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  MeasurementTrendDetailPage(definition: def),
                        ),
                      ),
                ),
              if (defs.isNotEmpty) const Divider(),
              const SizedBox(height: 20),
              ListTile(
                tileColor: Colors.deepPurple,
                textColor: Colors.white,
                title: Text(strings.measurementTrackNew),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const NewMeasurementItemPage(),
                    ),
                  );
                  if (changed == true && mounted) {
                    _reloadDefinitions();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

String _measurementLabel(
  AppLocalizations strings,
  MeasurementDefinition definition,
) {
  if (definition.type == MeasurementType.BodyWeight) {
    return strings.measurementWeight;
  }
  if (definition.type == MeasurementType.Hip) {
    return strings.measurementHips;
  }
  if (definition.type == MeasurementType.Shoulder) {
    return strings.measurementShoulders;
  }
  if (definition.type == MeasurementType.Calf) {
    return strings.measurementCalves;
  }
  return definition.name;
}
