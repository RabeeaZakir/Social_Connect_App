import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'others_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String searchQuery = "";
  bool isSearching = false;

  // --- 1. Notification Add Logic ---
  Future<void> _addNotification(String title, String message) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user!.uid,
        'title': title,
        'body': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Instant feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.deepPurple, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      print("Notification Error: $e");
    }
  }

  // --- 2. Notification Center (Bottom Sheet) ---
  void _showNotificationCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(margin: const EdgeInsets.all(10), width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: user!.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text("No notifications yet"));
                  
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      var nData = snap.data!.docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.notifications, color: Colors.white, size: 18)),
                        title: Text(nData['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(nData['body'] ?? ""),
                        trailing: Text(nData['timestamp'] != null ? timeago.format(nData['timestamp'].toDate()) : "just now", style: const TextStyle(fontSize: 10)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Comment System (Fixed) ---
  void _showComments(String postId) {
    TextEditingController commentC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(15), child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold))),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox(height: 50);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      var cData = snap.data!.docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(radius: 15, child: Text(cData['username']?[0] ?? "U")),
                        title: Text(cData['username'] ?? "User", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text(cData['text'] ?? ""),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: commentC, decoration: const InputDecoration(hintText: "Write a comment...", border: InputBorder.none))),
                  IconButton(icon: const Icon(Icons.send, color: Colors.deepPurple), onPressed: () async {
                    if (commentC.text.isNotEmpty) {
                      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                      await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add({
                        'text': commentC.text,
                        'username': userDoc['name'] ?? "User",
                        'userId': user!.uid,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      commentC.clear();
                      _addNotification("Comment", "You commented on a post");
                    }
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: !isSearching 
            ? const Text("Social Connect", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)) 
            : TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: "Search users...", border: InputBorder.none),
                onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() { isSearching = !isSearching; searchQuery = ""; }),
          ),
          // --- FIXED NOTIFICATION CLICK ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: user!.uid).snapshots(),
            builder: (context, snap) {
              int count = snap.hasData ? snap.data!.docs.length : 0;
              return GestureDetector(
                onTap: _showNotificationCenter,
                child: Container(
                  padding: const EdgeInsets.only(right: 15, top: 10),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
                      if (count > 0)
                        CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 8, color: Colors.white))),
                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _createNewPostDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isSearching ? _buildUserSearch() : _buildPostFeed(),
    );
  }

  // --- Search UI (Naam + Bio + Profile Click) ---
  Widget _buildUserSearch() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var users = snapshot.data!.docs.where((doc) {
          String name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? "";
          return name.contains(searchQuery);
        }).toList();
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            var data = users[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(backgroundImage: (data['profilePic'] != null && data['profilePic'] != "") ? NetworkImage(data['profilePic']) : null, child: (data['profilePic'] == null || data['profilePic'] == "") ? const Icon(Icons.person) : null),
                title: Text(data['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['bio'] ?? "No bio"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OthersProfileScreen(userId: users[i].id))),
              ),
            );
          },
        );
      },
    );
  }

  // --- Post Feed UI ---
  Widget _buildPostFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snapshot.data!.docs[i];
            var data = doc.data() as Map<String, dynamic>;
            List likes = data['likes'] ?? [];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OthersProfileScreen(userId: data['userId']))),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['username'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['timestamp'] != null ? timeago.format(data['timestamp'].toDate()) : "now"),
                    trailing: data['userId'] == user!.uid ? IconButton(icon: const Icon(Icons.more_horiz), onPressed: () => _showPostOptions(doc.id, data['caption'])) : null,
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), child: Text(data['caption'] ?? "")),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        icon: Icon(likes.contains(user!.uid) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                        label: Text("${likes.length}"),
                        onPressed: () {
                          var ref = FirebaseFirestore.instance.collection('posts').doc(doc.id);
                          if(likes.contains(user!.uid)) {
                            ref.update({'likes': FieldValue.arrayRemove([user!.uid])});
                          } else {
                            ref.update({'likes': FieldValue.arrayUnion([user!.uid])});
                            _addNotification("Like", "You liked ${data['username']}'s post");
                          }
                        },
                      ),
                      TextButton.icon(icon: const Icon(Icons.comment_outlined), label: const Text("Comment"), onPressed: () => _showComments(doc.id)),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _createNewPostDialog() {
    TextEditingController postC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("New Post", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: postC, maxLines: 3, decoration: const InputDecoration(hintText: "Share your thoughts...")),
            ElevatedButton(onPressed: () async {
              if(postC.text.isNotEmpty){
                var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                await FirebaseFirestore.instance.collection('posts').add({
                  'caption': postC.text,
                  'username': userDoc['name'] ?? "User",
                  'userId': user!.uid,
                  'timestamp': FieldValue.serverTimestamp(),
                  'likes': [],
                });
                Navigator.pop(context);
                _addNotification("Shared", "Your post is live!");
              }
            }, child: const Text("Post")),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(String docId, String currentCaption) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.edit), title: const Text("Edit"), onTap: () { Navigator.pop(context); _editPostDialog(docId, currentCaption); }),
          ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete"), onTap: () async {
            await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
            Navigator.pop(context);
            _addNotification("Deleted", "Post removed.");
          }),
        ],
      ),
    );
  }

  void _editPostDialog(String docId, String oldText) {
    TextEditingController editC = TextEditingController(text: oldText);
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Edit Post"), content: TextField(controller: editC),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(onPressed: () async {
        await FirebaseFirestore.instance.collection('posts').doc(docId).update({'caption': editC.text});
        Navigator.pop(context);
        _addNotification("Updated", "Post updated!");
      }, child: const Text("Save"))],
    ));
  }
}