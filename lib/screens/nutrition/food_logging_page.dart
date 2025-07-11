// File: lib/screens/food_logging_page.dart

import 'package:flutter/material.dart';
import 'food_customization_page.dart';

// if you want to use mini-charts here too

class FoodLoggingPage extends StatefulWidget {
  const FoodLoggingPage({super.key});

  @override
  State<FoodLoggingPage> createState() => _FoodLoggingPageState();
}

class _FoodLoggingPageState extends State<FoodLoggingPage> {
  // tab state: 0=Scan, 1=Search, 2=Pre-Planned, 3=Custom
  final List<bool> _tabs = [false, true, false, false];

  // TODO: replace with live state
  int selectedCalories = 500;
  int remainingCalories = 1500;
  int selectedFats = 10;
  int remainingFats = 40;
  int selectedProtein = 30;
  int remainingProtein = 70;
  int selectedCarbs = 80;
  int remainingCarbs = 120;

  // placeholder food list for Search
  List<Map<String, String>> _entries = [
    {'name': 'Olive Oil', 'cal': '80', 'macro': '0P 0F 9C', 'qty': '2 tsp'},
    {'name': 'Butter, Salted', 'cal': '36', 'macro': '0P 4F 0C', 'qty': '5g'},
    {'name': 'Chicken Cutlet', 'cal': '220', 'macro': '23P 8F 0C', 'qty': '1 cutlet'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Logging')),

      body: Column(
        children: [
          // ─── Top stats row ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _StatCard(label: 'Calories',    value: '$selectedCalories/$remainingCalories kcal')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Fats',        value: '$selectedFats/$remainingFats g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Protein',     value: '$selectedProtein/$remainingProtein g')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'Carbs',       value: '$selectedCarbs/$remainingCarbs g')),
              ],
            ),
          ),

          // ─── Tab selector ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ToggleButtons(
              isSelected: _tabs,
              onPressed: (i) => setState(() {
                for (var idx = 0; idx < _tabs.length; idx++) {
                  _tabs[idx] = idx == i;
                }
              }),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Scan')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Search')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Pre-Planned')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Custom')),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Content area ────────────────────────────────
          Expanded(
  child: _tabs[0]
      // Scan
      ? Center(child: Text('Scan interface coming soon'))
      // Search
      : _tabs[1]
          ? ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = _entries[i];
                return Card(
                  child: ListTile(
                    title: Text(e['name']!),
                    subtitle: Text('${e['macro']} • ${e['qty']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // TODO: mark this item for adding to log
                      },
                    ),
                  ),
                );
              },
            )
      // Pre-Planned
      : _tabs[2]
          ? Center(child: Text('Pre-Planned meals coming soon'))
          // Custom
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 1, // just the Add New bar for now
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return Card(
                  child: ListTile(
                    title: const Text('Add New Food Item'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FoodCustomizationPage(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
),


          // ─── Bottom search & add row ──────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // in Search tab this could be a real filter; in others, you might disable it
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a food...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (q) {
                      // TODO: filter _entries
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: batch-add selected items to log; for now:
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Food'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable small stat card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ensure it wraps tightly
        children: [
          // smaller label
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),      // less vertical gap
          // smaller value text
          Text(value, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
