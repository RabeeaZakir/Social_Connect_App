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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _uploadPost() async {
    if (_captionController.text.isEmpty) return;

    try {
      await _firestore.collection('posts').add({
        'caption': _captionController.text.trim(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context); // Screen band ho jayegi
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Uploaded!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Post")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: "Write a caption..."),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost, 
              child: const Text("Post to Firestore"),
            ),
          ],
        ),
      ),
    );
  }
}