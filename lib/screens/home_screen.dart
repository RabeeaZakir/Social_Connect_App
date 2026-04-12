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

  Future<void> _addNotification(String title, String message) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user!.uid,
        'title': title,
        'body': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$title: $message"),
          backgroundColor: Colors.deepPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print("Notification Error: $e");
    }
  }

  void _showNotificationCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(margin: const EdgeInsets.all(12), width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
            Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: user!.uid).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  if (snap.data!.docs.isEmpty) return const Center(child: Text("No notifications yet"));
                  return ListView.builder(
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      var n = snap.data!.docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.notifications, color: Colors.white, size: 18)),
                        title: Text(n['title'] ?? "Alert", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(n['body'] ?? "", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                        trailing: Text(n['timestamp'] != null ? timeago.format(n['timestamp'].toDate()) : "now", style: const TextStyle(fontSize: 10)),
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

  Widget _buildUserSearch() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var users = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = data.containsKey('name') ? data['name'].toString().toLowerCase() : "";
          return name.contains(searchQuery.toLowerCase());
        }).toList();
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            var data = users[i].data() as Map<String, dynamic>;
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(data['name'] ?? "User"),
              subtitle: Text(data['bio'] ?? "No bio"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OthersProfileScreen(userId: users[i].id))),
            );
          },
        );
      },
    );
  }

  // --- Post Feed Updated with Image URL Logic ---
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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(15), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OthersProfileScreen(userId: data['userId']))),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['username'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['timestamp'] != null ? timeago.format(data['timestamp'].toDate()) : "just now", style: const TextStyle(fontSize: 11)),
                    trailing: data['userId'] == user!.uid ? IconButton(icon: const Icon(Icons.more_horiz), onPressed: () => _showPostOptions(doc.id, data['caption'])) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), 
                    child: Text(data['caption'] ?? "", style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color))
                  ),

                  // --- IMAGE URL LOGIC ADDED HERE ---
                  if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data['imageUrl'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(), // Hide if URL is broken
                        ),
                      ),
                    ),

                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        icon: Icon(likes.contains(user!.uid) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                        label: Text("${likes.length}", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
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
                      TextButton.icon(
                        icon: const Icon(Icons.comment_outlined, color: Colors.deepPurpleAccent), 
                        label: Text("Comment", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)), 
                        onPressed: () => _showComments(doc.id)
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- New Post Modal with Image URL Field ---
  void _createNewPost() {
    TextEditingController postC = TextEditingController();
    TextEditingController urlC = TextEditingController(); // Controller for URL

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("New Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextField(
              controller: postC, 
              maxLines: 3, 
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(hintText: "What's on your mind?", border: InputBorder.none)
            ),
            const Divider(),
            TextField(
              controller: urlC, 
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(
                hintText: "Paste Image URL (Optional)", 
                prefixIcon: Icon(Icons.link, size: 20),
                border: InputBorder.none
              )
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 45)),
              onPressed: () async {
                if (postC.text.isNotEmpty) {
                  var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                  await FirebaseFirestore.instance.collection('posts').add({
                    'caption': postC.text,
                    'imageUrl': urlC.text.trim(), // Save URL to Firestore
                    'username': userDoc['name'] ?? "User",
                    'userId': user!.uid,
                    'timestamp': FieldValue.serverTimestamp(),
                    'likes': [],
                  });
                  Navigator.pop(context);
                  _addNotification("Shared", "Your post is now live!");
                }
              },
              child: const Text("Post Now", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _showComments(String postId) {
    TextEditingController commentC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: const EdgeInsets.all(15), child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
            SizedBox(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      var c = snap.data!.docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(c['username'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)), 
                        subtitle: Text(c['text'] ?? "", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: commentC, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), decoration: const InputDecoration(hintText: "Add comment..."))),
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

  void _showPostOptions(String id, String cap) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.edit), title: const Text("Edit"), onTap: () { Navigator.pop(context); _editDialog(id, cap); }),
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete"), onTap: () async { 
          await FirebaseFirestore.instance.collection('posts').doc(id).delete(); 
          Navigator.pop(context); 
        }),
    ]));
  }

  void _editDialog(String id, String cap) {
    TextEditingController editC = TextEditingController(text: cap);
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      content: TextField(controller: editC, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), 
        ElevatedButton(onPressed: () async { 
          await FirebaseFirestore.instance.collection('posts').doc(id).update({'caption': editC.text}); 
          Navigator.pop(context); 
        }, child: const Text("Update"))
      ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: !isSearching 
            ? const Text("Social Connect", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)) 
            : TextField(autofocus: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color), decoration: const InputDecoration(hintText: "Search...", border: InputBorder.none), onChanged: (val) => setState(() => searchQuery = val)),
        actions: [
          IconButton(icon: Icon(isSearching ? Icons.close : Icons.search), onPressed: () => setState(() { isSearching = !isSearching; searchQuery = ""; })),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: user!.uid).snapshots(),
            builder: (context, snap) {
              int count = snap.hasData ? snap.data!.docs.length : 0;
              return InkWell(
                onTap: _showNotificationCenter,
                child: Padding(padding: const EdgeInsets.only(right: 15, top: 12), child: Stack(alignment: Alignment.topRight, children: [const Icon(Icons.notifications_none, size: 28), if (count > 0) CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 8, color: Colors.white)))]))
              );
            }
          ),
        ],
      ),
      body: isSearching ? _buildUserSearch() : _buildPostFeed(),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.deepPurple, onPressed: _createNewPost, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}