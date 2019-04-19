import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senor/chat_page.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/profile_tidbit.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';
import 'package:senor/util/profile.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

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
                    builder: (context) => _ProfileRoute(uid: doc.documentID),
                  ),
                );
              },
              child: ListTile(
                leading: UserIcon(
                  photoUrl: doc['photoUrl'],
                  displayName: parseUserDisplayName(doc),
                ),
                title: Text(
                  parseUserDisplayName(doc),
                ),
                subtitle: Text(parseUserDescription(doc)),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileRoute extends StatelessWidget {
  final String uid;

  const _ProfileRoute({Key key, @required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _ProfileRouteDetails(uid: uid),
        ),
      ),
    );
  }
}

class _ProfileRouteDetails extends StatelessWidget {
  final String uid;

  const _ProfileRouteDetails({Key key, @required this.uid}) : super(key: key);

  _contactUser({BuildContext context, String toDisplayName}) async {
    // TODO: Add an alternative method of contacting a user
    // This could be a built-in messaging platform,
    // or a user-defined mode of communication.
    // Examples include WhatsApp, Facebook, Instagram.
    final curUser = await FirebaseAuth.instance.currentUser();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
              fromUid: curUser.uid,
              toUid: uid,
              toDisplayName: toDisplayName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').document(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final data = snapshot.data;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: UserIcon(
                radius: 48,
                photoUrl: data['photoUrl'],
                displayName: parseUserDisplayName(data),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    parseUserDisplayName(data),
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Text(
                    parseUserDescription(data),
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileTidbit(
                    data: parseUserReputation(data).toString(),
                    desc: 'REP',
                  ),
                  ProfileTidbit(
                    data: buildProfileDateString(
                      parseUserCreationTimestamp(data),
                    ),
                    desc: 'JOINED',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileTidbit(
                    data: parseUserGender(data),
                    desc: 'GENDER',
                  ),
                  ProfileTidbit(
                    data: parseUserRace(data),
                    desc: 'RACE',
                  ),
                  ProfileTidbit(
                    data: parseUserReligion(data),
                    desc: 'RELIGION',
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () => _contactUser(
                      context: context,
                      toDisplayName: parseUserDisplayName(data),
                    ),
                child: const Text('Contact Me'),
              ),
            ),
          ],
        );
      },
    );
  }
}
