import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OthersProfileScreen extends StatelessWidget {
  final String userId;
  const OthersProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("User Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("User profile not found."));

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              const SizedBox(height: 30),
              // Profile Picture Fix
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (userData['profilePic'] != null && userData['profilePic'] != "")
                      ? NetworkImage(userData['profilePic'])
                      : null,
                  child: (userData['profilePic'] == null || userData['profilePic'] == "")
                      ? const Icon(Icons.person, size: 60, color: Colors.deepPurple)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              Text(userData['name'] ?? "User", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(userData['bio'] ?? "No bio added.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              
              const SizedBox(height: 30),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("POSTS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
              ),

              // User specific posts grid
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: userId).snapshots(),
                  builder: (context, postSnap) {
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());
                    if (postSnap.data!.docs.isEmpty) return const Center(child: Text("No posts yet."));

                    return GridView.builder(
                      padding: const EdgeInsets.all(5),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
                      itemCount: postSnap.data!.docs.length,
                      itemBuilder: (context, index) {
                        var post = postSnap.data!.docs[index];
                        return Container(
                          color: Colors.deepPurple.withOpacity(0.05),
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Text(post['caption'] ?? "", 
                              maxLines: 3, 
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}