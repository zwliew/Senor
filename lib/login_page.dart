import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/loading_indicator.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.headline,
            ),
            RaisedButton(
              color: Colors.white,
              child: const Text('Sign in with email'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _EmailRoute(),
                  ),
                );
              },
            ),
            GoogleSignInButton(
              onPressed: _signIn,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _EmailRouteBody(),
      ),
    );
  }
}

class _EmailRouteBody extends StatefulWidget {
  @override
  createState() => _EmailRouteBodyState();
}

class _EmailRouteBodyState extends State<_EmailRouteBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _authenticating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            validator: (value) {
              if (value.isEmpty) return 'Please enter an email';
              if (!RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                  .hasMatch(value)) return 'Please enter a valid email';
            },
            controller: _emailController,
            decoration: const InputDecoration(
              prefixIcon: const Icon(Icons.email),
              labelText: 'Email',
            ),
          ),
          _PasswordFormField(
            controller: _passwordController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _authenticating
                ? const LoadingIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Colors.white,
                        child: const Text('Sign up'),
                        onPressed: () async {
                          if (!_formKey.currentState.validate()) return;

                          setState(() => _authenticating = true);

                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            Navigator.pop(context);
                          } on PlatformException catch (e) {
                            setState(() => _authenticating = false);

                            String errorText;
                            switch (e.code) {
                              case 'ERROR_EMAIL_ALREADY_IN_USE':
                                errorText =
                                    'Email already exists. Try signing in instead.';
                                break;
                              case 'ERROR_INVALID_EMAIL':
                                errorText =
                                    'Invalid email. Please enter a valid email.';
                                break;
                              case 'ERROR_WEAK_PASSWORD':
                                errorText =
                                    'Weak password. Please enter a stronger password.';
                                break;
                              default:
                                errorText =
                                    'Failed to sign up. Please check your details.';
                                break;
                            }
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorText),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 16.0),
                      RaisedButton(
                        child: const Text('Sign in'),
                        onPressed: () async {
                          if (!_formKey.currentState.validate()) return;

                          setState(() => _authenticating = true);

                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            Navigator.pop(context);
                          } on PlatformException catch (e) {
                            setState(() => _authenticating = false);

                            String errorText;
                            switch (e.code) {
                              case 'ERROR_WRONG_PASSWORD':
                                errorText = 'Wrong password. Please try again.';
                                break;
                              case 'ERROR_USER_NOT_FOUND':
                                errorText =
                                    'User does not exist. Try signing up instead.';
                                break;
                              case 'ERROR_INVALID_EMAIL':
                                errorText =
                                    'Invalid email. Please enter a valid email.';
                                break;
                              case 'ERROR_TOO_MANY_REQUESTS':
                                errorText =
                                    'Too many attempts. Please try again later.';
                                break;
                              default:
                                errorText =
                                    'Failed to sign in. Please check your details.';
                                break;
                            }
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorText),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PasswordFormField extends StatefulWidget {
  final TextEditingController controller;

  const _PasswordFormField({Key key, this.controller}) : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<_PasswordFormField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) return 'Please enter a password';
        if (value.length < 8)
          return 'Password must be at least 8 characters long';
      },
      controller: widget.controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
    );
  }
}
