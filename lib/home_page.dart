import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senor/my_chats_page.dart';
import 'package:senor/discover_page.dart';
import 'package:senor/my_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum _PopupMenuOptions { logout }

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

  _buildSelectedPageWidget() {
    switch (_selectedIdx) {
      case _discoverIdx:
        return const DiscoverPage();
      case _profileIdx:
        return const MyProfilePage();
      case _chatsIdx:
      default:
        return const MyChatsPage();
    }
  }

  _buildPageTitleWidget() {
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
        title: _buildPageTitleWidget(),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.person),
            tooltip: 'Profile settings',
            onSelected: (result) {
              switch (result) {
                case _PopupMenuOptions.logout:
                  FirebaseAuth.instance.signOut();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _PopupMenuOptions.logout,
                    child: const ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Log out'),
                    ),
                  ),
                ],
          )
        ],
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
        onTap: _handleNavigationItemTap,
      ),
    );
  }
}
