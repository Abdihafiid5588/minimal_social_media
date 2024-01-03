import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_social_media/auth/login_or_register.dart';
import 'package:minimal_social_media/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user signed in
          if (snapshot.hasData) {
            return HomePage();

          }
          //user is not logged in 
          else {
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}