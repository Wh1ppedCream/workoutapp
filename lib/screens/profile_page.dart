// File: lib/profile_page.dart
import 'package:flutter/material.dart';
import 'measured_items_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: const Text('Profile')),
  body: Column(
    children: [
      // Measurements bar
      ListTile(
        leading: const Icon(Icons.timeline),
        title: const Text('Measurements'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MeasuredItemsPage()),
        ),
      ),
      // TODO: User info bar
      ListTile(leading: Icon(Icons.person), title: Text('User Info')),
      // TODO: Settings bar
      ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
    ],
  ),
);
  }
}
