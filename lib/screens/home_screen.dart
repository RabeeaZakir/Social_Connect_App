import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Feed"), // const hataya
        actions: [
          IconButton(
            icon: Icon(Icons.person), // const hataya
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout), // const hataya
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        // const hataya
        child: Text("Welcome to Social Connect!"), // const hataya
      ),
    );
  }
}
