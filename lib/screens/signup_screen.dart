import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (value) => !value!.contains('@') ? "Enter valid email" : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  validator: (value) => value!.length < 6 ? "Min 6 characters" : null,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context); // Signup ke baad wapas login pe
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Created! Please Login")));
                    }
                  },
                  child: Text("Register"),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}