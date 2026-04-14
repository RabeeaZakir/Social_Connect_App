import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController imgController = TextEditingController();
  bool _isLoading = false;

  void updateProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name cannot be empty!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'profilePic': imgController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated!"), backgroundColor: Colors.green));
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
        title: Text("Edit Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          if (nameController.text.isEmpty && !_isLoading) {
            nameController.text = userData['name'] ?? "";
            bioController.text = userData['bio'] ?? "";
            imgController.text = userData['profilePic'] ?? "";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.purpleAccent.withOpacity(0.3),
                  backgroundImage: (userData['profilePic'] != null && userData['profilePic'] != "")
                      ? NetworkImage(userData['profilePic']) : null,
                  child: (userData['profilePic'] == null || userData['profilePic'] == "")
                      ? const Icon(Icons.person, size: 70, color: Colors.white) : null,
                ),
                const SizedBox(height: 30),
                _buildProfileField("Full Name", nameController, Icons.person),
                const SizedBox(height: 20),
                _buildProfileField("Bio", bioController, Icons.info_outline),
                const SizedBox(height: 20),
                _buildProfileField("Profile Image URL", imgController, Icons.link),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("SAVE CHANGES", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(alignment: Alignment.centerLeft, child: Text("MY POSTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const Divider(color: Colors.white24),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: currentUserId).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> postSnap) {
                    if (!postSnap.hasData) return const CircularProgressIndicator();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
                      itemCount: postSnap.data!.docs.length,
                      itemBuilder: (context, index) {
                        var post = postSnap.data!.docs[index];
                        return Container(
                          color: Colors.grey[900],
                          child: post['imageUrl'] != "" ? Image.network(post['imageUrl'], fit: BoxFit.cover) : const Icon(Icons.text_snippet, color: Colors.white24),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
        ),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.purpleAccent),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}