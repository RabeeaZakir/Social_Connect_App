import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedPostsScreen extends StatelessWidget {
  const LikedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("My Liked Posts")),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore query jo sirf user ke liked posts layegi
        stream: FirebaseFirestore.instance.collection('posts').where('likes', arrayContains: uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No liked posts yet!"));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              var data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(data['username'] ?? "User"),
                  subtitle: Text(data['caption']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}