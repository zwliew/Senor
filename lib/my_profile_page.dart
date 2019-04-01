import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senor/loading_page.dart';
import 'package:senor/user_icon.dart';
import 'package:senor/util/debouncer.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Future<Map<String, dynamic>> _profile;
  DocumentReference _ref;

  @override
  void initState() {
    super.initState();

    _profile = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final user = await FirebaseAuth.instance.currentUser();
    _ref = Firestore.instance.collection('users').document(user.uid);
    final snapshot = await _ref.get();
    return snapshot.data;
  }

  _buildJoinedString(ms) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      ms,
      isUtc: true,
    );
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  _buildTextFieldWidget({String label, IconData icon, String field}) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      title: MyProfileTextField(
        label: label,
        icon: icon,
        ref: _ref,
        field: field,
      ),
    );
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
          padding: const EdgeInsets.all(8.0),
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
              Column(
                children: [
                  const Divider(),
                  const Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text(
                      'Education background',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTextFieldWidget(
                    field: 'universityAttended',
                    label: 'University Attended',
                    icon: Icons.account_balance,
                  ),
                  _buildTextFieldWidget(
                    field: 'coursesPursued',
                    label: 'Courses pursued',
                    icon: Icons.book,
                  ),
                  _buildTextFieldWidget(
                    field: 'highSchoolAttended',
                    label: 'High school attended',
                    icon: Icons.account_balance,
                  ),
                  _buildTextFieldWidget(
                    field: 'extracurricularsTaken',
                    label: 'Extracurriculars taken',
                    icon: Icons.golf_course,
                  ),
                  _buildTextFieldWidget(
                    field: 'leadershipPositions',
                    label: 'Leadership positions',
                    icon: Icons.people,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyProfileTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final DocumentReference ref;
  final String field;

  const MyProfileTextField({
    Key key,
    @required this.label,
    @required this.icon,
    @required this.ref,
    @required this.field,
  }) : super(key: key);

  @override
  _MyProfileTextFieldState createState() => _MyProfileTextFieldState();
}

class _MyProfileTextFieldState extends State<MyProfileTextField> {
  // Delay in milliseconds after a text change to be sure
  // that the user is not currently typing
  static const _textEditDelayMs = 750;

  final _controller = TextEditingController();
  final _debouncer = Debouncer();
  StreamSubscription _subscription;
  int _lastEditedMs = 0;

  @override
  void initState() {
    super.initState();

    _subscription = widget.ref.snapshots().listen((snapshot) {
      setState(() {
        // Only update the TextEditingController when:
        // 1. The text was not changed by the user in the app
        // 2. The user is not currently editing the text
        if (_controller.text != snapshot.data[widget.field] &&
            DateTime.now().millisecondsSinceEpoch - _lastEditedMs >
                _textEditDelayMs) {
          _controller.text = snapshot.data[widget.field];
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();

    super.dispose();
  }

  void _handleValueChange(value) {
    _lastEditedMs = DateTime.now().millisecondsSinceEpoch;
    _debouncer.run(_textEditDelayMs, () {
      Firestore.instance.runTransaction((tx) async {
        await tx.update(widget.ref, {
          widget.field: value.trim(),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        border: const OutlineInputBorder(),
        labelText: widget.label,
      ),
      controller: _controller,
      onChanged: _handleValueChange,
    );
  }
}
