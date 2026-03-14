import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController(), _pass = TextEditingController(), _name = TextEditingController(), _confirm = TextEditingController();
  bool _isLogin = true;

  // AuthScreen ke _submit function mein ye update karo
// AuthScreen mein ye logic use karen
Future<void> _submit() async {
  try {
    if (!_isLogin) {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(), 
        password: _pass.text.trim()
      );
      
      // Yahan 'name' field lazmi save karni hai
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': _name.text.trim(), // Yahan se naam jayega
        'email': _email.text.trim(),
        'bio': "Hey there! I am new.",
      });
    } else {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_isLogin) TextField(controller: _name, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            if (!_isLogin) TextField(controller: _confirm, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
            ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "Login" : "Sign Up")),
            TextButton(onPressed: () => FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text), child: const Text("Forgot Password?")),
            TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "Create Account" : "Back to Login")),
          ],
        ),
      ),
    );
  }
}