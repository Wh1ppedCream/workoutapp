// lib/screens/combined_history_page.dart
import 'package:material_ui/material_ui.dart';

class CombinedHistoryPage extends StatelessWidget {
  const CombinedHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combined History')),
      body: const Center(child: Text('Combined History content')),
    );
  }
}
