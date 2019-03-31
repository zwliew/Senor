import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_color/random_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIdx = 0;

  void _handleNavigationItemTap(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  Widget _buildSelectedPageWidget() {
    switch (_selectedIdx) {
      case 1:
        return DiscoverPage();
      case 0:
      default:
        return MessagesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildSelectedPageWidget(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            title: const Text('Messages'),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            title: const Text('Discover'),
          )
        ],
        currentIndex: _selectedIdx,
        fixedColor: Colors.blue,
        onTap: _handleNavigationItemTap,
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  static const _peers = [
    'Timmy',
    'Samantha',
    'Zac',
    'Linda',
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the Messages page
    return ListView(
      children: _peers.map((name) => ListTile(title: Text(name))).toList(),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: const CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data.documents;
        return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileRoute(uid: doc.documentID),
                    ),
                  );
                },
                child: ListTile(
                  leading: UserIcon(
                    photoUrl: doc['photoUrl'],
                  ),
                  title: Text(doc['displayName']),
                ),
              );
            });
      },
    );
  }
}

class UserIcon extends StatelessWidget {
  static final _randomColor = RandomColor();
  final String displayName;
  final String photoUrl;
  final double radius;

  const UserIcon({Key key, this.displayName, this.photoUrl, this.radius = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display the user's photo if available
    if (photoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    // Otherwise, display the user's initials with a random BG color
    if (displayName != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: _randomColor.randomColor(),
        child: Text(displayName
            .split(' ')
            .take(2)
            .map((s) => s.substring(0, 1))
            .join('')
            .toUpperCase()),
      );
    }

    // Else, display a smiley face with a random BG color
    return CircleAvatar(
      radius: radius,
      backgroundColor: _randomColor.randomColor(),
      child: const Text(':D'),
    );
  }
}

class ProfileRoute extends StatelessWidget {
  final uid;

  const ProfileRoute({Key key, @required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: StreamBuilder(
        stream:
            Firestore.instance.collection('users').document(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          final data = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserIcon(
                      radius: 48,
                      photoUrl: data['photoUrl'],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['displayName'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          data['reputation'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Opacity(
                          opacity: 0.8,
                          child: Text('REP'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
