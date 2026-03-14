import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OthersProfileScreen extends StatelessWidget {
  final String userId;
  const OthersProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("User profile details not found."));

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              const SizedBox(height: 30),
              const Center(child: CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60))),
              const SizedBox(height: 20),
              Text(userData['name'] ?? "User", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(userData['bio'] ?? "No bio available", style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const Divider(height: 40),
              const Text("User Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          );
        },
      ),
    );
  }
}