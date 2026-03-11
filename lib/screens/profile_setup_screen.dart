import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _bioController, decoration: const InputDecoration(labelText: "Bio")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Yahan data Global Provider mein save ho raha hai
                context.read<UserProvider>().updateProfile(_nameController.text, _bioController.text);
                Navigator.pop(context);
              },
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}