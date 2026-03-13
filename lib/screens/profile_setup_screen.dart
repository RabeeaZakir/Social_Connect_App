import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)), // Profile Pic
                Text(data['name'] ?? "User", style: const TextStyle(fontSize: 24)),
                ListTile(title: Text("Bio: ${data['bio'] ?? 'No bio'}")),
                ListTile(title: Text("Contact: ${data['contact'] ?? 'N/A'}")),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}