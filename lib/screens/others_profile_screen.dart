import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class OthersProfileScreen extends StatefulWidget {
  final String userId;
  const OthersProfileScreen({required this.userId, super.key});

  @override
  State<OthersProfileScreen> createState() => _OthersProfileScreenState();
}

class _OthersProfileScreenState extends State<OthersProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _getFollowStats();
  }

  void _checkFollowStatus() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .doc(currentUserId)
        .get();
    if (mounted) setState(() => isFollowing = doc.exists);
  }

  void _getFollowStats() {
    FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('followers').snapshots().listen((snap) {
      if (mounted) setState(() => followerCount = snap.docs.length);
    });
    FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('following').snapshots().listen((snap) {
      if (mounted) setState(() => followingCount = snap.docs.length);
    });
  }

  void _toggleFollow() async {
    var userRef = FirebaseFirestore.instance.collection('users');
    if (isFollowing) {
      await userRef.doc(widget.userId).collection('followers').doc(currentUserId).delete();
      await userRef.doc(currentUserId).collection('following').doc(widget.userId).delete();
    } else {
      await userRef.doc(widget.userId).collection('followers').doc(currentUserId).set({'at': DateTime.now()});
      await userRef.doc(currentUserId).collection('following').doc(widget.userId).set({'at': DateTime.now()});
    }
    setState(() => isFollowing = !isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (widget.userId != currentUserId)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(widget.userId).get().then((doc) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => ChatScreen(receiverId: widget.userId, receiverName: doc['name'])));
                });
              },
            )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(radius: 50, child: userData['profilePic'] == null ? const Icon(Icons.person, size: 50) : null),
              const SizedBox(height: 10),
              Text(userData['name'] ?? "User", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [Text("$followerCount", style: const TextStyle(fontWeight: FontWeight.bold)), const Text("Followers")]),
                  Column(children: [Text("$followingCount", style: const TextStyle(fontWeight: FontWeight.bold)), const Text("Following")]),
                ],
              ),
              const SizedBox(height: 15),
              if (widget.userId != currentUserId)
                ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(backgroundColor: isFollowing ? Colors.grey : Colors.deepPurple),
                  child: Text(isFollowing ? "Unfollow" : "Follow", style: const TextStyle(color: Colors.white)),
                ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: widget.userId).snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, i) => Container(
                        margin: const EdgeInsets.all(2),
                        color: Colors.grey[300],
                        child: Center(child: Text(snap.data!.docs[i]['caption'] ?? "", style: const TextStyle(fontSize: 10))),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}