import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  void _uploadPost() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Post ka data Firestore mein bhej rahe hain
      await FirebaseFirestore.instance.collection('posts').add({
        'text': _textController.text.trim(),
        'imageUrl': _urlController.text.trim(), // URL field
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });

      Navigator.pop(context); // Post hone ke baad wapis Home par
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: const Color(0xFF0E1B48),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _uploadPost,
            icon: const Icon(Icons.done, color: Colors.purpleAccent),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.grey),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Paste Image URL here (Optional)",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.link, color: Colors.purpleAccent),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}