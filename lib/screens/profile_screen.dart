import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Add google_fonts to pubspec.yaml if possible

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool _isLoading = false;

  void updateProfile() async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'name': nameController.text,
      'bio': bioController.text,
    });
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!", style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Forced deep black
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.purpleAccent,));
          
          var data = snapshot.data!.data() as Map<String, dynamic>;
          nameController.text = data['name'];
          bioController.text = data['bio'] ?? "No bio available";

          return CustomScrollView(
            slivers: [
              // Modern Profile Header with Gradient and Picture
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF0E1B48), Colors.deepPurpleAccent.withOpacity(0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.purple,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        data['name'],
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        data['email'],
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      // Stats Row (Followers, Following, Posts)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("${data['postsCount'] ?? 0}", "Posts"),
                          _buildStatItem("${data['followersCount'] ?? 0}", "Followers"),
                          _buildStatItem("${data['followingCount'] ?? 0}", "Following"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Editable Fields Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Edit Details", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                      _buildProfileField("Full Name", nameController, Icons.person),
                      const SizedBox(height: 15),
                      _buildProfileField("Bio", bioController, Icons.chat_bubble_outline),
                      const SizedBox(height: 30),
                      // Save Changes Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: Colors.white,) 
                            : Text("SAVE CHANGES", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.purpleAccent),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1C2D5A).withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}