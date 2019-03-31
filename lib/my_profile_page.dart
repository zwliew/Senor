import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senor/loading_page.dart';
import 'package:senor/user_icon.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Future<Map<String, dynamic>> _profile;

  @override
  void initState() {
    super.initState();

    _profile = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final user = await FirebaseAuth.instance.currentUser();
    final ref = Firestore.instance.collection('users').document(user.uid);
    final snapshot = await ref.get();
    return snapshot.data;
  }

  _buildJoinedString(ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      ms,
      isUtc: true,
    );
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _profile,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingPage();
        }

        final data = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
                          child: Text('REP'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          _buildJoinedString(data['creationTimestamp']),
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
            ],
          ),
        );
      },
    );
  }
}
