import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Yeh raha _addPost function
  void _addPost(BuildContext context) {
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Post"),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: "What's on your mind?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (c.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('posts').add({
                  'caption': c.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  // Yeh raha _updatePost function
  void _updatePost(BuildContext context, String id, String oldText) {
    TextEditingController c = TextEditingController(text: oldText);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Post"),
        content: TextField(controller: c),
        actions: [
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('posts').doc(id).update({'caption': c.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              var doc = snapshot.data!.docs[i];
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['caption'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _updatePost(context, doc.id, data['caption'])),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => doc.reference.delete()),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPost(context), // Ab yahan error nahi aayega
        child: const Icon(Icons.add),
      ),
    );
  }
}