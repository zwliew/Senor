import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_icon.dart';

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