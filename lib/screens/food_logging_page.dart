// File: lib/screens/food_logging_page.dart

import 'package:flutter/material.dart';

/// Page for searching, adding, and viewing today’s food logs.
class FoodLoggingPage extends StatefulWidget {
  const FoodLoggingPage({Key? key}) : super(key: key);

  @override
  State<FoodLoggingPage> createState() => _FoodLoggingPageState();
}

class _FoodLoggingPageState extends State<FoodLoggingPage> {
  // TODO: Replace with your real search results / today's entries
  List<Map<String, String>> _entries = [
    {'name': 'Apple',      'qty': '1',  'unit': 'piece', 'cal': '95'},
    {'name': 'Oatmeal',    'qty': '1',  'unit': 'cup',   'cal': '150'},
    {'name': 'Chicken',    'qty': '100','unit': 'g',     'cal': '165'},
  ];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Logging')),
      body: Column(
        children: [
          // ─── Search bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (q) {
                setState(() => _searchQuery = q);
                // TODO: perform live search against your food database
              },
            ),
          ),

          // ─── Quick-add buttons ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Barcode'),
                    onPressed: () {
                      // TODO: launch barcode scanner
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Add Manually'),
                    onPressed: () {
                      // TODO: open manual entry form
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // ─── Today’s entries ───────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = _entries[i];
                return Card(
                  child: ListTile(
                    title: Text('${e['qty']} ${e['unit']} ${e['name']}'),
                    trailing: Text('${e['cal']} kcal'),
                    onTap: () {
                      // TODO: edit this entry
                    },
                  ),
                );
              },
            ),
          ),

          // ─── Daily total ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  // TODO: sum up real calories
                  '${_entries.map((e) => int.parse(e['cal']!)).reduce((a, b) => a + b)} kcal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),

      // ─── Add new entry FAB ───────────────────────────
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: open quick-add dialog (search or manual)
        },
      ),
    );
  }
}
