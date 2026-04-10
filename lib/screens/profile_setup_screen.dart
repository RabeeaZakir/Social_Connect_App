import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user!.uid}.jpg');
        await ref.putFile(File(pickedFile.path));
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profilePic': url});
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          // Controller value set karte waat cursor ka masla na ho isliye ye logic:
          if (_nameController.text.isEmpty)
            _nameController.text = data['name'] ?? "";
          if (_bioController.text.isEmpty)
            _bioController.text = data['bio'] ?? "";

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepPurple, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: isDark
                            ? Colors.grey[900]
                            : Colors.grey[200],
                        backgroundImage:
                            (data['profilePic'] != null &&
                                data['profilePic'] != "")
                            ? NetworkImage(data['profilePic'])
                            : null,
                        child:
                            (data['profilePic'] == null ||
                                data['profilePic'] == "")
                            ? Icon(
                                Icons.person,
                                size: 70,
                                color: isDark ? Colors.white24 : Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 40),

              _editField("Full Name", _nameController, isDark),
              const SizedBox(height: 20),
              _editField("Bio", _bioController, isDark, maxLines: 3),

              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .update({
                          'name': _nameController.text,
                          'bio': _bioController.text,
                        });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated!")),
                    );
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
      ),
    );
  }
}
