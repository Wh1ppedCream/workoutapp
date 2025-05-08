// File: lib/train_page.dart
import 'package:flutter/material.dart';
import 'session_screen.dart';

class TrainPage extends StatelessWidget {
  const TrainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Train')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Preset session cards
            Card(
              child: ListTile(
                title: const Text('Push'),
                onTap: () {
                  // TODO: load preset
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Pull'),
                onTap: () {
                  // TODO: load preset
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SessionScreen()),
                );
              },
              child: const Text('New Session'),
            ),
          ],
        ),
      ),
    );
  }
}