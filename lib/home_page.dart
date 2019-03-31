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

        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  final user = snapshot.data.documents[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileRoute(
                            profile: UserProfile(
                              username: user['name'],
                              name: user['name'],
                              reputation: user['reputation'],
                              isAdmin: user['isAdmin'],
                            ),
                          ),
                    ),
                  );
                },
                child: ListTile(
                  leading:
                      UserIcon(name: snapshot.data.documents[index]['name']),
                  title: Text(snapshot.data.documents[index]['name']),
                ),
              );
            });
      },
    );
  }
}

class UserIcon extends StatelessWidget {
  final String name;

  const UserIcon({Key key, @required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RandomColor color = RandomColor();
    return CircleAvatar(
      backgroundColor: color.randomColor(),
      child: Text(name.substring(0, 2)),
    );
  }
}

class UserProfile {
  final String username;
  final String name;
  final int reputation;
  final bool isAdmin;

  const UserProfile({this.username, this.name, this.reputation, this.isAdmin});
}

class ProfileRoute extends StatelessWidget {
  final profile;

  const ProfileRoute({Key key, @required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Column(
          children: [
            UserIcon(name: profile.name.substring(0, 2)),
          ],
        ));
  }
}