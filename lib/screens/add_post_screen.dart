import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  final String? postId; 
  final String? existingText;
  final String? existingUrl;

  const AddPostScreen({super.key, this.postId, this.existingText, this.existingUrl});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late TextEditingController _textController;
  late TextEditingController _urlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingText ?? "");
    _urlController = TextEditingController(text: widget.existingUrl ?? "");
  }

  void _submitPost() async {
    if (_textController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      var postData = {
        'text': _textController.text.trim(),
        'imageUrl': _urlController.text.trim(),
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.postId == null) {
        // Nayi Post Banana
        await FirebaseFirestore.instance.collection('posts').add({...postData, 'likes': []});
      } else {
        // Purani Post Edit Karna
        await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(postData);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.postId == null ? "Create Post" : "Edit Post"),
        backgroundColor: const Color(0xFF0E1B48),
        actions: [
          IconButton(onPressed: _isLoading ? null : _submitPost, icon: const Icon(Icons.check, color: Colors.purpleAccent))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(hintText: "What's on your mind?", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
            ),
            const Divider(color: Colors.grey),
            TextField(
              controller: _urlController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Paste Image URL here",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.link, color: Colors.purpleAccent),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            if (_urlController.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _urlController.text,
                  height: 200, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100, color: Colors.grey[900],
                    child: const Center(child: Text("Image URL is not valid", style: TextStyle(color: Colors.white))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}