import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart'; // Yahan apna sahi path check kar lena
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Feed ka data
  List<Map<String, dynamic>> posts = [
    {"username": "Rabeea", "caption": "Hello world!", "isLiked": false},
  ];

  void _addNewPost(String caption) {
    setState(() {
      posts.insert(0, {"username": "My Post", "caption": caption, "isLiked": false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
      // Yahan Consumer use kiya hai taake Provider ka data real-time update ho
      body: Column(
        children: [
          // Profile Status Header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<UserProvider>(
              builder: (context, user, child) {
                return Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    title: Text("Name: ${user.name}"),
                    subtitle: Text("Bio: ${user.bio}"),
                  ),
                );
              },
            ),
          ),
          // Post Feed
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(posts[index]['username']),
                    subtitle: Text(posts[index]['caption']),
                    trailing: IconButton(
                      icon: Icon(
                        posts[index]['isLiked'] ? Icons.favorite : Icons.favorite_border,
                        color: posts[index]['isLiked'] ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => setState(() => posts[index]['isLiked'] = !posts[index]['isLiked']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddPostScreen(onPostAdded: _addNewPost))),
        child: const Icon(Icons.add),
      ),
    );
  }
}