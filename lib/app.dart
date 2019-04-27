import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/home_page.dart';
import 'package:senor/login_page.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/loading_indicator.dart';

class App extends StatelessWidget {
  static const _title = 'Senor';

  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.redAccent,
      ),
      navigatorObservers: [Analytics.observer],
      home: const _AppHome(title: _title),
    );
  }
}

class _AppHome extends StatefulWidget {
  final String title;

  const _AppHome({Key key, @required this.title}) : super(key: key);

  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  @override
  Widget build(BuildContext context) {
    final curUserBloc = BlocProvider.of<CurrentUserBloc>(context);
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          Firestore.instance
              .collection('users')
              .where('uid', isEqualTo: user.uid)
              .getDocuments()
              .then((snapshot) {
            if (snapshot.documents.length == 0) {
              curUserBloc.dispatch(LoggedOut());
              return;
            }
            final doc = snapshot.documents[0];
            curUserBloc.dispatch(LoggedIn(doc.documentID));
          });
          return const HomePage();
        }

        return LoginPage(title: widget.title);
      },
    );
  }
}
