import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Hum ye file abhi banayenge

void main() {
  runApp(SocialConnectApp());
}

class SocialConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Sab se pehle Login dikhega
    );
  }
}