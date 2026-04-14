import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OthersProfileScreen extends StatefulWidget {
  final String userId;
  OthersProfileScreen({required this.userId});

  @override
  _OthersProfileScreenState createState() => _OthersProfileScreenState();
}

class _OthersProfileScreenState extends State<OthersProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  void checkIfFollowing() async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUserId).collection('following').doc(widget.userId).get();
    if (mounted) setState(() => isFollowing = doc.exists);
  }

  Future<void> toggleFollow() async {
    try {
      if (isFollowing) {
        await _firestore.collection('users').doc(currentUserId).collection('following').doc(widget.userId).delete();
        await _firestore.collection('users').doc(widget.userId).collection('followers').doc(currentUserId).delete();
        await _firestore.collection('users').doc(currentUserId).update({'followingCount': FieldValue.increment(-1)});
        await _firestore.collection('users').doc(widget.userId).update({'followersCount': FieldValue.increment(-1)});
      } else {
        await _firestore.collection('users').doc(currentUserId).collection('following').doc(widget.userId).set({});
        await _firestore.collection('users').doc(widget.userId).collection('followers').doc(currentUserId).set({});
        await _firestore.collection('users').doc(currentUserId).update({'followingCount': FieldValue.increment(1)});
        await _firestore.collection('users').doc(widget.userId).update({'followersCount': FieldValue.increment(1)});
      }
      if (mounted) setState(() => isFollowing = !isFollowing);
    } catch (e) {
      debugPrint("Follow Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(widget.userId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (userData['profilePic'] != null && userData['profilePic'] != "")
                    ? NetworkImage(userData['profilePic']) : null,
                child: (userData['profilePic'] == null || userData['profilePic'] == "")
                    ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
              const SizedBox(height: 10),
              Text(userData['name'] ?? "User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(userData['bio'] ?? "No bio available", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statItem("${userData['followersCount'] ?? 0}", "Followers"),
                  const SizedBox(width: 30),
                  _statItem("${userData['followingCount'] ?? 0}", "Following"),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey[800] : Colors.purpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(150, 40),
                ),
                child: Text(isFollowing ? "Unfollow" : "Follow", style: const TextStyle(color: Colors.white)),
              ),
              const Divider(color: Colors.white24, height: 30),
              Expanded(
                child: StreamBuilder(
                  stream: _firestore.collection('posts').where('uid', isEqualTo: widget.userId).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> postSnap) {
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());
                    if (postSnap.data!.docs.isEmpty) return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.white54)));

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem(String count, String label) => Column(children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))
      ]);
}