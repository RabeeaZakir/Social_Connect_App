import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart'; // Ensure this matches your file name
import 'home_screen.dart';
import 'liked_post_screen.dart';
import 'profile_setup_screen.dart';
import 'add_post_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List of screens for the Bottom Navigation Bar
  final List<Widget> _screens = [
    const HomeScreen(),
    const LikedPostsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensuring theme is consistent
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      
      // Fixed AppBar with Search and Notifications
      appBar: AppBar(
        title: const Text(
          "Social Connect",
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        actions: [
          // Search functionality wapis add kar di hai
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              // Add your search logic here if needed
            },
          ),
          // Notification badge jo video mein missing tha
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.red,
                  child: Text("3", style: TextStyle(fontSize: 8, color: Colors.white)),
                ),
              )
            ],
          ),
        ],
      ),

      // Current screen display
      body: _screens[_currentIndex],

      // Fixed Floating Action Button to call Add Post correctly
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // Bottom Navigation Bar setup
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Liked"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}