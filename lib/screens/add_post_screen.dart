import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  final Function(String) onPostAdded;
  const AddPostScreen({super.key, required this.onPostAdded});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "What's on your mind?"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onPostAdded(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}