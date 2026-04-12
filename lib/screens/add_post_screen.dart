
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart'; // Ensure this matches your file name
import 'dart:io';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  final _captionController = TextEditingController();
  bool _loading = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // Gallery se image uthane ke liye
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // Post upload karne ka mukammal function
  Future<void> _uploadPost() async {
    if (_image == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add image and caption")));
      return;
    }

    setState(() => _loading = true);
    try {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 1. Storage mein save karna
      Reference ref = FirebaseStorage.instance.ref().child('posts').child('$id.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      // 2. Firestore mein data save karna (Comment, Like, Edit options ke liye fields add kardi hain)
      await FirebaseFirestore.instance.collection('posts').doc(id).set({
        'postId': id,
        'uid': user!.uid,
        'postUrl': imageUrl,
        'caption': _captionController.text.trim(),
        'username': user?.email?.split('@')[0] ?? "User",
        'likes': [], // Future likes ke liye
        'commentsCount': 0, // Comments handle karne ke liye
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Shared Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text("Create Post", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            onPressed: _uploadPost,
            child: const Text("Post", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 18)),
          )
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple)) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Image Picker Box
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _image != null 
                      ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_image!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: isDark ? Colors.white38 : Colors.grey),
                            const Text("Select Photo"),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                // Caption Field
                TextField(
                  controller: _captionController,
                  maxLines: 4,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDark ? Colors.white12 : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 20),
                // Notification/Search placeholders (UI only as per your request)
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
                  title: const Text("Tip: Add a great caption to get more engagement!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          ),
    );
  }
}
