import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_color/random_color.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _chatsIdx = 0;
  static const _discoverIdx = 1;
  static const _profileIdx = 2;
  static const _chatsTitle = 'Chats';
  static const _discoverTitle = 'Discover';
  static const _profileTitle = 'Profile';

  int _selectedIdx = 0;

  void _handleNavigationItemTap(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  Widget _buildSelectedPageWidget() {
    switch (_selectedIdx) {
      case _discoverIdx:
        return DiscoverPage();
      case _profileIdx:
        return MyProfilePage();
      case _chatsIdx:
      default:
        return ChatsPage();
    }
  }

  Text _buildPageTitle() {
    String title;
    switch (_selectedIdx) {
      case _discoverIdx:
        title = _discoverTitle;
        break;
      case _profileIdx:
        title = _profileTitle;
        break;
      case _chatsIdx:
      default:
        title = _chatsTitle;
        break;
    }
    return Text(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildPageTitle(),
      ),
      body: _buildSelectedPageWidget(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            title: const Text(_chatsTitle),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            title: const Text(_discoverTitle),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text(_profileTitle),
          ),
        ],
        currentIndex: _selectedIdx,
        fixedColor: Colors.blue,
        onTap: _handleNavigationItemTap,
      ),
    );
  }
}

class ChatsPage extends StatelessWidget {
  static const _peers = [
    'Timmy',
    'Samantha',
    'Zac',
    'Linda',
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the ChatsPage
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

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
