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
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final ref = FirebaseStorage.instance.ref().child('user_images').child('${user!.uid}.jpg');
        await ref.putFile(File(pickedFile.path));
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'profilePic': url});
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? "";
          _bioController.text = data['bio'] ?? "";

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.deepPurple, width: 3)),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: data['profilePic'] != null ? NetworkImage(data['profilePic']) : null,
                        child: data['profilePic'] == null ? const Icon(Icons.person, size: 70, color: Colors.grey) : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 20,
                        child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18), onPressed: _pickImage),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isUploading) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator()),
              const SizedBox(height: 40),
              _editField("Full Name", _nameController),
              const SizedBox(height: 20),
              _editField("Bio", _bioController, maxLines: 3),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                      'name': _nameController.text,
                      'bio': _bioController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
                  },
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontSize: 16))),
            ],
          );
        },
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
        filled: true,
        // YAHAN FIX HAI:
        fillColor: Colors.grey[100]?.withOpacity(0.5) ?? Colors.white, 
      ),
    );
  }
}