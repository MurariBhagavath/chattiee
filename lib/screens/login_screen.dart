import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.showSignUp});
  final VoidCallback showSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future signIn() async {
    await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Logged in successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CHATTIEE',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.pink.shade300),
                ),
                label: Text('Email'),
              ),
            ),
            SizedBox(height: 18),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.pink.shade300),
                ),
                label: Text('Password'),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {
                  signIn();
                },
                child: Text('Login')),
            SizedBox(height: 32),
            GestureDetector(
                onTap: widget.showSignUp,
                child: Text('New user? click here to signup')),
          ],
        ),
      ),
    );
  }
}
