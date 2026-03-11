import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Social Connect", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 40),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()), validator: (v) => v!.contains('@') ? null : "Invalid Email"),
              SizedBox(height: 20),
              TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), validator: (v) => v!.length >= 6 ? null : "Too short"),
              SizedBox(height: 30),
              ElevatedButton(onPressed: _handleLogin, child: Text("Login")),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())), child: Text("Sign Up instead"))
            ],
          ),
        ),
      ),
    );
  }
}