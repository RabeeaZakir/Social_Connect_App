import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "Guest User";
  String _bio = "No bio yet";

  String get name => _name;
  String get bio => _bio;

  void updateProfile(String newName, String newBio) {
    _name = newName;
    _bio = newBio;
    notifyListeners(); // Yeh command poori app ko bata degi ke data update ho gaya hai
  }
}