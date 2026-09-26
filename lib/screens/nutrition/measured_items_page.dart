// File: lib/screens/nutrition/measured_items_page.dart

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/health_trends_section.dart';

class MeasuredItemsPage extends StatefulWidget {
  const MeasuredItemsPage({super.key});

  @override
  State<MeasuredItemsPage> createState() => _MeasuredItemsPageState();
}

class _MeasuredItemsPageState extends State<MeasuredItemsPage> {
  bool _changed = false;

  void _markChanged() => _changed = true;

  void _pop() => Navigator.of(context).pop(_changed);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.nutritionMeasuredItems),
          leading: BackButton(onPressed: _pop),
        ),
        body: HealthTrendsSection(fullPage: true, onChanged: _markChanged),
      ),
    );
  }
}
