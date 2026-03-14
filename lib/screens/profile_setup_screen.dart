import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      final ref = FirebaseStorage.instance.ref().child('user_images').child('${user!.uid}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'profilePic': url});
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? "";
          _bioController.text = data['bio'] ?? "";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(children: [
                  CircleAvatar(radius: 60, backgroundImage: data['profilePic'] != null ? NetworkImage(data['profilePic']) : null, child: data['profilePic'] == null ? const Icon(Icons.person, size: 60) : null),
                  Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.deepPurple, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20), onPressed: _pickImage))),
                ]),
              ),
              if(_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
              const SizedBox(height: 30),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
              const SizedBox(height: 15),
              TextField(controller: _bioController, decoration: const InputDecoration(labelText: "Bio", filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
              const SizedBox(height: 30),
              FilledButton(onPressed: () => FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'name': _nameController.text, 'bio': _bioController.text}), child: const Text("Save Changes")),
              TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text("Logout", style: TextStyle(color: Colors.red))),
            ],
          );
        },
      ),
    );
  }
}