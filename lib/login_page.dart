import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  final String title;

  const LoginPage({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Welcome to $title'),
        RaisedButton(
          onPressed: () async {
            final googleSignIn = GoogleSignIn();
            final googleUser = await googleSignIn.signIn();
            if (googleUser == null) return;

            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.getCredential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            FirebaseAuth.instance.signInWithCredential(credential);
          },
          child: const Text('Login with Google'),
        ),
      ],
    );
  }
}
