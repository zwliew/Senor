import 'package:flutter/material.dart';
import './discover_page.dart';
import './my_profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _chatsIdx = 0;
  static const _chatsTitle = 'My Chats';
  static const _chatsLabel = 'Chats';

  static const _discoverIdx = 1;
  static const _discoverTitle = 'Discover';
  static const _discoverLabel = _discoverTitle;

  static const _profileIdx = 2;
  static const _profileTitle = 'My Profile';
  static const _profileLabel = 'Profile';

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
            title: const Text(_chatsLabel),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            title: const Text(_discoverLabel),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text(_profileLabel),
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
