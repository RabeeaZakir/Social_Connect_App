import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'others_profile_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

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
            child: const Text("Update"),
          ),
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
                FirebaseFirestore.instance.collection('posts').add({
                  'caption': c.text,
                  'username': username,
                  'userId': user!.uid,
                  'timestamp': FieldValue.serverTimestamp(),
                  'likes': [],
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Post"),
          ),
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
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(docId).collection('comments').orderBy('timestamp').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, i) {
                        var com = snapshot.data!.docs[i];
                        return ListTile(
                          leading: const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 15)),
                          title: Text(com['username'] ?? "User", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(com['text']),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(children: [
                Expanded(child: TextField(controller: c, decoration: const InputDecoration(hintText: "Write a comment..."))),
                IconButton(icon: const Icon(Icons.send, color: Colors.deepPurple), onPressed: () async {
                  if (c.text.isNotEmpty) {
                    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                    String username = userDoc.data()?['name'] ?? "User";
                    FirebaseFirestore.instance.collection('posts').doc(docId).collection('comments').add({
                      'text': c.text, 'username': username, 'timestamp': FieldValue.serverTimestamp(),
                    });
                    c.clear();
                  }
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
              
              // 3 DOTS LOGIC: Agar userId exist karti hai aur meri hai
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
                        onTap: () {
                          // NAVIGATION TO OTHER PROFILE
                          if (data['userId'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OthersProfileScreen(userId: data['userId']),
                              ),
                            );
                          }
                        },
                        child: Text(
                          data['username'] ?? "User", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, decoration: TextDecoration.underline),
                        ),
                      ),
                      subtitle: const Text("Recently"),
                      // WAPIS AAGAYE 3 DOTS
                      trailing: isMyPost ? PopupMenuButton(
                        onSelected: (val) {
                          if (val == 'edit') _editPost(doc.id, data['caption']);
                          if (val == 'delete') FirebaseFirestore.instance.collection('posts').doc(doc.id).delete();
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                        ],
                      ) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(alignment: Alignment.centerLeft, child: Text(data['caption'] ?? "", style: const TextStyle(fontSize: 16))),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        IconButton(icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey), onPressed: () => _toggleLike(doc.id, likes)),
                        Text("${likes.length}"),
                        const SizedBox(width: 20),
                        IconButton(icon: const Icon(Icons.mode_comment_outlined), onPressed: () => _showComments(context, doc.id)),
                        const Text("Comment"),
                      ],
                    ),
                    const SizedBox(height: 8),
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