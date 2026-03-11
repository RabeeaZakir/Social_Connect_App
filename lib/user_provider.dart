import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "Guest User";
  String _bio = "No bio yet";

  String get name => _name;
  String get bio => _bio;

  // Firebase se data lane ke liye hum ek method add karenge
  void updateProfile(String newName, String newBio) {
    _name = newName;
    _bio = newBio;
    notifyListeners(); 
  }
}