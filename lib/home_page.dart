import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/my_chats_page.dart';
import 'package:senor/discover_page.dart';
import 'package:senor/my_profile_page.dart';
import 'package:senor/profile_route.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';

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

  final _discoverPageSearchDelegate = _DiscoverPageSearchDelegate();

  int _selectedIdx = 0;

  void _handleNavigationItemTap(int index) {
    String screenName;
    String screenClassOverride;
    switch (index) {
      case _discoverIdx:
        screenName = 'discover';
        screenClassOverride = 'DiscoverPage';
        break;
      case _profileIdx:
        screenName = 'my_profile';
        screenClassOverride = 'MyProfilePage';
        break;
      case _chatsIdx:
      default:
        screenName = 'my_chats';
        screenClassOverride = 'MyChatsPage';
        break;
    }
    Analytics.analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClassOverride,
    );

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
          if (_selectedIdx == _discoverIdx)
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {
                Analytics.analytics.setCurrentScreen(
                  screenName: 'search',
                  screenClassOverride: 'DiscoverPageSearchDelegate',
                );
                showSearch(
                  context: context,
                  delegate: _discoverPageSearchDelegate,
                );
              },
            ),
          PopupMenuButton(
            tooltip: 'Options',
            onSelected: (result) {
              switch (result) {
                case _PopupMenuOptions.logout:
                  Analytics.analytics.logEvent(name: 'logout');
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

class _DiscoverPageSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<CurrentUserEvent, CurrentUser>(
      bloc: BlocProvider.of<CurrentUserBloc>(context),
      builder: (context, curUser) => StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data.documents
                  .where((doc) =>
                      doc.documentID != curUser.id &&
                      parseUserDisplayName(doc)
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                  .toList();

              if (docs.length == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: const Icon(
                          Icons.search,
                          size: 120.0,
                        ),
                      ),
                      Text(
                        'No results',
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return ListTile(
                    leading: UserIcon(
                      photoUrl: doc['photoUrl'],
                      displayName: parseUserDisplayName(doc),
                    ),
                    title: Text(
                      parseUserDisplayName(doc),
                    ),
                    subtitle: Text(parseUserDescription(doc)),
                    onTap: () => navigateToProfile(
                          context: context,
                          profileId: doc.documentID,
                        ),
                  );
                },
              );
            },
          ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
