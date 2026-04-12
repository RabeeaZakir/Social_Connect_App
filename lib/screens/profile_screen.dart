import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  void updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'name': nameController.text,
      'bio': bioController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          var data = snapshot.data!;
          nameController.text = data['name'];
          bioController.text = data['bio'] ?? "";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
                TextField(controller: bioController, decoration: InputDecoration(labelText: "Bio")),
                SizedBox(height: 20),
                ElevatedButton(onPressed: updateProfile, child: Text("Save Changes")),
              ],
            ),
          );
        },
      ),
    );
  }
}