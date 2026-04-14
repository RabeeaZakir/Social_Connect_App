import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();

      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _userData = doc.data();
      
      _isLoading = false;
      notifyListeners();
    }
  }
}