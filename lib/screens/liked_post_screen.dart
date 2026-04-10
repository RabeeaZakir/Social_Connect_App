import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart'; 

class LikedPostsScreen extends StatelessWidget {
  const LikedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text("Liked Posts", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').where('likes', arrayContains: uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("You haven't liked anything yet!", 
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              var data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  border: isDark ? Border.all(color: Colors.white10) : null,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent, 
                    child: Icon(Icons.favorite, color: Colors.white)
                  ),
                  title: Text(data['username'] ?? "User", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  subtitle: Text(data['caption'] ?? "", 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}