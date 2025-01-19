import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluenteer/Screens/Login_Screen.dart';
import 'package:fluenteer/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003366), // Dark blue for background

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Bankable",
              style: TextStyle(
                fontSize: 45,
                color: Colors.white, // Crisp white for title
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Simplify spending, amplify savings.",
            style: TextStyle(
              fontSize: 22, // Slightly smaller font for subtitle
              color: Colors.white70, // Muted white for contrast
            ),
          ),

          SizedBox(height: 80),

          Align(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(
              color: Colors.lightBlueAccent, // Light blue accent for activity indicator
            ),
          ),
        ],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const MyHomePage(title: "app");
    }
    return LoginScreen();
  }
}
