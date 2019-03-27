import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './login_page.dart';
import './home_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  static const _title = 'Senor';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const AppHome(title: _title),
    );
  }
}

class AppHome extends StatelessWidget {
  final String title;

  const AppHome({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WaitingPage();
          }
          if (snapshot.hasData) {
            return HomePage(title: title);
          }
          return LoginPage(title: title);
        });
  }
}

class WaitingPage extends StatelessWidget {
  const WaitingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Loading app...'),
        const CircularProgressIndicator(),
      ],
    );
  }
}
