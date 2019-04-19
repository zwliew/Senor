import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/login_page.dart';
import 'package:senor/home_page.dart';

class App extends StatelessWidget {
  static const _title = 'Senor';

  static final _analytics = FirebaseAnalytics();
  static final _observer = FirebaseAnalyticsObserver(analytics: _analytics);

  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.redAccent,
      ),
      navigatorObservers: [_observer],
      home: const _AppHome(title: _title),
    );
  }
}

class _AppHome extends StatelessWidget {
  final String title;

  const _AppHome({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        final user = snapshot.data;
        if (snapshot.hasData) {
          return HomePage(user: user);
        }
        return LoginPage(title: title);
      },
    );
  }
}
