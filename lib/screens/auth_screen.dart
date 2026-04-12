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
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  void _submit() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(), 
          password: _pass.text.trim()
        );
      } else {
        if (_pass.text != _confirmPass.text) throw Exception("Passwords don't match!");
        
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(), 
          password: _pass.text.trim()
        );

        // Yahan humne naye user ke liye default fields add kar di hain
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid, // UID store karna hamesha acha hota hai
          'name': _name.text.trim(), 
          'email': _email.text.trim(),
          'bio': "Hey there! I am using Social Connect.",
          'profilePic': null,
          'followersCount': 0, // Default 0 for new users
          'followingCount': 0, // Default 0 for new users
        });
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "An error occurred");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1B48),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1B48), Color(0xFF1C2D5A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Icon(Icons.share_arrival_time_outlined, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text("Social Connect", 
                  style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Text("Connect with the world", 
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 40),
                if (!_isLogin) _buildField(_name, "Full Name", Icons.person),
                const SizedBox(height: 15),
                _buildField(_email, "Email", Icons.email),
                const SizedBox(height: 15),
                _buildField(_pass, "Password", Icons.lock, obscure: true),
                if (!_isLogin) ...[
                  const SizedBox(height: 15),
                  _buildField(_confirmPass, "Confirm Password", Icons.lock_clock, obscure: true),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0E1B48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : Text(_isLogin ? "LOGIN" : "CREATE ACCOUNT", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? "New here? Create an account" : "Already have an account? Login", 
                    style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF0E1B48)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        hintText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}