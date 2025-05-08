import 'package:flutter/material.dart';

class SessionScreen extends StatefulWidget {
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Workout')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // TODO: Exercise cards go here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new exercise
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Finish workout
          },
          child: Text('Finish Workout'),
        ),
      ),
    );
  }
}
