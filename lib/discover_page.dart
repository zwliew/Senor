import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/profile_tidbit.dart';
import 'package:senor/ui/user_icon.dart';
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
                  ),
                  title: Text(doc['displayName']),
                  subtitle: Text(doc['describeMyself']),
                ),
              );
            });
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
  final uid;

  const _ProfileRouteDetails({Key key, @required this.uid}) : super(key: key);

  _contactUser() {
    // TODO: Add a method of contacting a user
    // This could be a built-in messaging platform,
    // or a user-defined mode of communication.
    // Examples include WhatsApp, Facebook, Instagram.
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    data['displayName'],
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Text(
                    data['describeMyself'],
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
                    data: data['reputation'].toString(),
                    desc: 'REP',
                  ),
                  ProfileTidbit(
                    data: buildProfileDateString(data['creationTimestamp']),
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
                    data: data['gender'],
                    desc: 'GENDER',
                  ),
                  ProfileTidbit(
                    data: data['race'],
                    desc: 'RACE',
                  ),
                  ProfileTidbit(
                    data: data['religion'],
                    desc: 'RELIGION',
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: _contactUser,
                child: const Text('Contact Me'),
              ),
            ),
          ],
        );
      },
    );
  }
}
