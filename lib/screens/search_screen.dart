import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'others_profile_screen.dart'; // Make sure this path is correct

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search users...",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            onChanged: (val) {
              setState(() {
                query = val.toLowerCase();
              });
            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found"));
          }

          // Filtering logic based on name
          var results = snapshot.data!.docs.where((doc) {
            String name = doc['name'] ?? '';
            return name.toLowerCase().contains(query);
          }).toList();

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              var userData = results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(userData['name'] ?? 'No Name', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userData['email'] ?? ''),
                onTap: () {
                  // Navigate to Others Profile Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OthersProfileScreen(userId: userData.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}