import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
// Agar user_provider file nahi hai, toh ye line hatana mat bhoolna!
import '../user_provider.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Feed")),
      body: Column(
        children: [
          // User Profile Card
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<UserProvider>(
              builder: (context, user, child) => Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  title: Text("Name: ${user.name}"),
                  subtitle: Text("Bio: ${user.bio}"),
                ),
              ),
            ),
          ),
          // Firestore se Data fetch karna
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No posts yet!"));
                }
                
                var posts = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(post['caption'] ?? 'No Caption'),
                        subtitle: Text("User ID: ${post['userId']}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const AddPostScreen())
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}