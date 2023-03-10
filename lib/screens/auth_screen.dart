import 'package:chattiee/screens/login_screen.dart';
import 'package:chattiee/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;
  void toggleScreen(){
    setState(() {
      showLogin = !showLogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showLogin){
      return LoginScreen(showSignUp: toggleScreen);
    }else{
      return SignUpScreen(showLogin: toggleScreen);

    }
  }
}
