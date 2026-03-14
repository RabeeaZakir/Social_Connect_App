import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Yahan se notification plugin aa raha hai
import 'others_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Notification Function
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channel_id', 'Social Connect',
        importance: Importance.max, priority: Priority.high);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, const NotificationDetails(android: androidDetails));
  }

  void _editPost(String docId, String currentCaption) {
    TextEditingController c = TextEditingController(text: currentCaption);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Post"),
        content: TextField(controller: c, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('posts').doc(docId).update({'caption': c.text});
                Navigator.pop(context);
              },
              child: const Text("Update")),
        ],
      ),
    );
  }

  void _addPost(BuildContext context) {
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create New Post"),
        content: TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: "What's on your mind?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (c.text.isNotEmpty) {
                  var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                  String username = userDoc.data()?['name'] ?? "User";
                  await FirebaseFirestore.instance.collection('posts').add({
                    'caption': c.text,
                    'username': username,
                    'userId': user!.uid,
                    'timestamp': FieldValue.serverTimestamp(),
                    'likes': [],
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Post")),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, String docId) {
    TextEditingController c = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(15), child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(docId).collection('comments').orderBy('timestamp').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, i) => ListTile(title: Text(snapshot.data!.docs[i]['text'])),
                    );
                  },
                ),
              ),
              Row(children: [
                Expanded(child: TextField(controller: c, decoration: const InputDecoration(hintText: "Comment..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: () async {
                   await FirebaseFirestore.instance.collection('posts').doc(docId).collection('comments').add({'text': c.text, 'timestamp': FieldValue.serverTimestamp()});
                   c.clear();
                })
              ])
            ],
          ),
        ),
      ),
    );
  }

  void _toggleLike(String docId, List likes) {
    DocumentReference ref = FirebaseFirestore.instance.collection('posts').doc(docId);
    if (likes.contains(user!.uid)) {
      ref.update({'likes': FieldValue.arrayRemove([user!.uid])});
    } else {
      ref.update({'likes': FieldValue.arrayUnion([user!.uid])});
      showNotification("New Like!", "Someone liked your post.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Connect"), centerTitle: true),
      floatingActionButton: FloatingActionButton(onPressed: () => _addPost(context), child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              var doc = snapshot.data!.docs[i];
              var data = doc.data() as Map<String, dynamic>;
              List likes = data['likes'] ?? [];
              bool isLiked = likes.contains(user!.uid);
              var timestamp = data['timestamp'] as Timestamp?;
              String timeAgo = timestamp != null ? timeago.format(timestamp.toDate()) : "Recently";
              bool isMyPost = data['userId'] == user!.uid;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OthersProfileScreen(userId: data['userId']))),
                        child: Text(data['username'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, decoration: TextDecoration.underline)),
                      ),
                      subtitle: Text(timeAgo),
                      trailing: isMyPost ? PopupMenuButton(
                        onSelected: (val) {
                          if (val == 'edit') _editPost(doc.id, data['caption']);
                          if (val == 'delete') FirebaseFirestore.instance.collection('posts').doc(doc.id).delete();
                        },
                        itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text("Edit")), const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red)))],
                      ) : null,
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Align(alignment: Alignment.centerLeft, child: Text(data['caption'] ?? ""))),
                    const Divider(),
                    Row(
                      children: [
                        IconButton(icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey), onPressed: () => _toggleLike(doc.id, likes)),
                        Text("${likes.length}"),
                        IconButton(icon: const Icon(Icons.mode_comment_outlined), onPressed: () => _showComments(context, doc.id)),
                        const Text("Comment"),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}