// File: lib/screens/exercise/preset_generation_qa.dart

import 'package:flutter/material.dart';

class PresetGenerationQaScreen extends StatefulWidget {
  const PresetGenerationQaScreen({super.key});

  @override
  State<PresetGenerationQaScreen> createState() => _PresetGenerationQaScreenState();
}

class _PresetGenerationQaScreenState extends State<PresetGenerationQaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sessionDurationController = TextEditingController();
  final TextEditingController _weeklyFrequencyController = TextEditingController();

  @override
  void dispose() {
    _sessionDurationController.dispose();
    _weeklyFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Custom Presets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'How many minutes do you spend in the gym per session?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sessionDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 60',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How many times per week do you work out?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weeklyFrequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 5',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
