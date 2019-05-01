import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senor/singletons.dart';

class LoginPage extends StatelessWidget {
  final String title;

  const LoginPage({Key key, @required this.title}) : super(key: key);

  _signIn() async {
    // Sign in with Google
    // TODO: Support more login methods
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // Do nothing if the user cancelled the login process
      return;
    }

    // Authenticate with Firebase using Google credentials
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);

    Analytics.analytics.logLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title),
          Center(
            child: RaisedButton(
              onPressed: _signIn,
              child: const Text('Login with Google'),
            ),
          ),
        ],
      ),
    );
  }
}
