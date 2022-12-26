import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.showLogin});
  final VoidCallback showLogin;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _usersDb = FirebaseFirestore.instance.collection('users');

  Future signUp() async {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      var user = await _auth
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim())
          .then((user) {
        user.user!.updateDisplayName(_nameController.text);
      });
      await _usersDb.doc(_auth.currentUser!.uid).set({
        "uid": _auth.currentUser!.uid,
        "full name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "friends": [],
        "requests": [],
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter password correctly')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.pink.shade300),
                    ),
                    label: Text('Full Name'),
                  ),
                ),
                SizedBox(height: 18),
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
                SizedBox(height: 18),
                TextField(
                  controller: _confirmPasswordController,
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
                    label: Text('Confirm Password'),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                    onPressed: () {
                      signUp();
                    },
                    child: Text('Signup')),
                SizedBox(height: 32),
                GestureDetector(
                    onTap: widget.showLogin,
                    child: Text('Already a user? Login here')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
