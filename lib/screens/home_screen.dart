import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Feed")),
      body: Center(child: Text("Welcome to Social Connect!", style: TextStyle(fontSize: 18))),
    );
  }
}