import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  final _name = TextEditingController();
  bool _isLogin = true;

  // Error Popup function
  void _showError(String message) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Error"), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  void _submit() async {
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      } else {
        if (_pass.text != _confirmPass.text) return _showError("Passwords don't match!");
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({'name': _name.text, 'email': _email.text});
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "An error occurred");
    }
  }

  void _forgotPassword() async {
    if (_email.text.isEmpty) return _showError("Enter email first!");
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
    _showError("Password reset link sent to your email.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1B48),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text("Social Connect", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              if (!_isLogin) TextField(controller: _name, decoration: _inputDec("Full Name")),
              const SizedBox(height: 10),
              TextField(controller: _email, decoration: _inputDec("Email")),
              const SizedBox(height: 10),
              TextField(controller: _pass, obscureText: true, decoration: _inputDec("Password")),
              const SizedBox(height: 10),
              if (!_isLogin) TextField(controller: _confirmPass, obscureText: true, decoration: _inputDec("Confirm Password")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text(_isLogin ? "LOGIN" : "SIGN UP")),
              TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "Don't have an account? Sign Up" : "Have account? Login")),
              if (_isLogin) TextButton(onPressed: _forgotPassword, child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(filled: true, fillColor: Colors.white, labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));
}