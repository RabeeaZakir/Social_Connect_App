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

  void _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    // Yahan saari fields zaroor daalo jo HomeScreen read kar raha hai
    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user!.uid,
      'username': user.email, // Ya tum user collection se naam fetch karo
      'caption': _captionController.text,
      'imageUrl': 'https://picsum.photos/400', 
      'createdAt': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Column(
        children: [
          TextField(controller: _captionController, decoration: const InputDecoration(labelText: "Caption")),
          ElevatedButton(onPressed: _submitPost, child: const Text("Post to Feed")),
        ],
      ),
    );
  }
}