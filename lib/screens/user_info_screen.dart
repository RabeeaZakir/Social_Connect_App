import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserInfoScreen({super.key, required this.userId, required this.userName});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  // Local states for switches (Real app mein ye database se linked hote hain)
  bool isChatLocked = false;
  bool isTranslateOn = false;

  // --- BLOCK USER FUNCTION ---
  void _blockUser() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block ${widget.userName}?"),
        content: const Text("Blocked users will no longer be able to message you."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
                'blockedUsers': FieldValue.arrayUnion([widget.userId])
              });
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to chat
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Blocked")));
            },
            child: const Text("Block", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Contact Info"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Text(data['name'] ?? widget.userName, 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(data['email'] ?? '', 
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 30),
                
                _buildInfoTile(Icons.image, "Media visibility", () {}),
                _buildInfoTile(Icons.timer, "Disappearing messages", () {}, subtitle: "Off"),
                
                // Functional Switch for Chat Lock
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.white),
                  title: const Text("Chat lock", style: TextStyle(color: Colors.white)),
                  trailing: Switch(
                    value: isChatLocked,
                    onChanged: (val) {
                      setState(() => isChatLocked = val);
                    },
                    activeColor: Colors.purpleAccent,
                  ),
                ),

                _buildInfoTile(Icons.security, "Advanced chat privacy", () {}, subtitle: "Off"),

                // Functional Switch for Translation
                ListTile(
                  leading: const Icon(Icons.translate, color: Colors.white),
                  title: const Text("Translate messages", style: TextStyle(color: Colors.white)),
                  trailing: Switch(
                    value: isTranslateOn,
                    onChanged: (val) {
                      setState(() => isTranslateOn = val);
                    },
                    activeColor: Colors.purpleAccent,
                  ),
                ),

                _buildInfoTile(Icons.favorite_border, "Add to Favourites", () {}),
                
                // Functional Block Button
                _buildInfoTile(Icons.block, "Block ${data['name']}", _blockUser, color: Colors.red),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, VoidCallback onTap, {String? subtitle, Color color = Colors.white}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}