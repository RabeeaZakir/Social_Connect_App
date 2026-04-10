import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/settings_screen.dart'; // Import this for ThemeProvider
import 'screens/main_nav.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/liked_post_screen.dart';
import 'screens/add_post_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'user_provider.dart';
// Baqi screens import karein...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Register theme
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Connect',
      
      // Global Theme Logic: Pure app par deep black forced
      theme: themeProvider.currentTheme, 
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const MainWrapper() : const AuthScreen(); // Login screen
        },
      ),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const LikedPostsScreen(), const ProfileScreen(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    // Current theme check karein
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        
        // Navigation Bar ka color bi black karein
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
        
        type: BottomNavigationBarType.fixed,
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