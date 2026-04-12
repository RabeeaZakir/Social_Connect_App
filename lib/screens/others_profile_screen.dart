import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OthersProfileScreen extends StatefulWidget {
  final String userId; // The ID of the user we are viewing

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

  // Check if current user is already following this person
  void checkIfFollowing() async {
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(widget.userId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  Future<void> toggleFollow() async {
    if (isFollowing) {
      // Unfollow Logic
      await _firestore.collection('users').doc(currentUserId).collection('following').doc(widget.userId).delete();
      await _firestore.collection('users').doc(widget.userId).collection('followers').doc(currentUserId).delete();

      await _firestore.collection('users').doc(currentUserId).update({'followingCount': FieldValue.increment(-1)});
      await _firestore.collection('users').doc(widget.userId).update({'followersCount': FieldValue.increment(-1)});
    } else {
      // Follow Logic
      await _firestore.collection('users').doc(currentUserId).collection('following').doc(widget.userId).set({});
      await _firestore.collection('users').doc(widget.userId).collection('followers').doc(currentUserId).set({});

      await _firestore.collection('users').doc(currentUserId).update({'followingCount': FieldValue.increment(1)});
      await _firestore.collection('users').doc(widget.userId).update({'followersCount': FieldValue.increment(1)});
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(widget.userId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          var userData = snapshot.data!;
          return Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              Text(userData['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(userData['bio'] ?? "No bio available"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [Text("${userData['followersCount'] ?? 0}"), Text("Followers")]),
                  SizedBox(width: 30),
                  Column(children: [Text("${userData['followingCount'] ?? 0}"), Text("Following")]),
                ],
              ),
              ElevatedButton(
                onPressed: toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey : Colors.purple,
                ),
                child: Text(isFollowing ? "Unfollow" : "Follow"),
              ),
            ],
          );
        },
      ),
    );
  }
}