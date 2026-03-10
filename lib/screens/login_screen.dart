import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Social Connect", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 40),
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || !value.contains('@')) return "Enter a valid email";
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.length < 6) return "Password must be 6+ chars";
                  return null;
                },
              ),
              SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text("Login"),
              ),
              
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                child: Text("Don't have an account? Sign Up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}