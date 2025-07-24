import 'package:flutter/material.dart';

class UserInformationSettingsPage extends StatefulWidget {
  const UserInformationSettingsPage({super.key});

  @override
  State<UserInformationSettingsPage> createState() => _UserInformationSettingsPageState();
}

class _UserInformationSettingsPageState extends State<UserInformationSettingsPage> {
  // TODO: Replace placeholders with actual user data and controllers
  final TextEditingController _nameController = TextEditingController(text: 'Placeholder Name');
  final TextEditingController _userIdController = TextEditingController(text: '123456');
  final TextEditingController _emailController = TextEditingController(text: 'user@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final TextEditingController _dobController = TextEditingController(text: '01/01/1990');
  String _gender = 'Male'; // TODO: Load actual gender value

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
              // TODO: Implement onChanged to update name
            ),
            const SizedBox(height: 16),

            // User ID (read-only)
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Email Address
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
              // TODO: Implement onChanged to update email
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
              // TODO: Implement onChanged to update phone number
            ),
            const SizedBox(height: 16),

            // Date of Birth
            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'MM/DD/YYYY',
              ),
              keyboardType: TextInputType.datetime,
              // TODO: Replace with date picker widget
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
              items: <String>[
                'Male',
                'Female',
                'Other',
                'Prefer not to say'
              ].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _gender = value;
                  });
                  // TODO: Save gender selection
                }
              },
            ),
            const SizedBox(height: 16),

            // TODO: Add additional fields (e.g. profile picture, address) as needed
          ],
        ),
      ),
    );
  }
}
