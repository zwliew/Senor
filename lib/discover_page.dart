import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/profile.dart';

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
                      builder: (context) => _ProfileRoute(uid: doc.documentID),
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

class _ProfileRoute extends StatelessWidget {
  final String uid;

  _ProfileRoute({Key key, @required this.uid}) : super(key: key);

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

  _ProfileRouteDetails({Key key, @required this.uid}) : super(key: key);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        data['reputation'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Opacity(
                        opacity: 0.8,
                        child: const Text('REP'),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        buildProfileDateString(data['creationTimestamp']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Opacity(
                        opacity: 0.8,
                        child: const Text('JOINED'),
                      ),
                    ],
                  ),
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
