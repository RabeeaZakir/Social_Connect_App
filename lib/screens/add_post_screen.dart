import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _captionController = TextEditingController();
  bool _isLoading = false; // Loading indicator ke liye

  void _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_captionController.text.isEmpty || user == null) return;

    setState(() => _isLoading = true);

    try {
      // Data Firestore mein save karna
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'username': user.email ?? "User", 
        'caption': _captionController.text,
        'imageUrl': 'https://picsum.photos/400', 
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [], // Ye field HomeScreen ke liye zaroori hai
      });

      // MOUNTED CHECK: Yahan check kar rahay hain ke screen abhi tak open hai ya nahi
      if (!mounted) return; 

      // Agar open hai, toh screen band karo
      Navigator.pop(context);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController, 
              decoration: const InputDecoration(labelText: "Caption", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _submitPost, child: const Text("Post to Feed")),
          ],
        ),
      ),
    );
  }
}