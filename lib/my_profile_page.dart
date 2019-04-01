import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/profile_tidbit.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/debouncer.dart';
import 'package:senor/util/profile.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _PageDetails(),
      ),
    );
  }
}

class _PageDetails extends StatefulWidget {
  @override
  _PageDetailsState createState() => _PageDetailsState();
}

class _PageDetailsState extends State<_PageDetails> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _profile,
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
              child: Text(
                data['displayName'],
                style: const TextStyle(fontSize: 20),
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
            const Divider(),
            Text(
              'About myself',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DropDownListItem(
                    ref: _ref,
                    field: 'gender',
                    values: const [
                      'Male',
                      'Female',
                      'Others',
                    ],
                  ),
                  _DropDownListItem(
                    ref: _ref,
                    field: 'religion',
                    values: const [
                      'Buddhist',
                      'Christian',
                      'Free thinker',
                      'Hindu',
                      'Islam',
                      'Roman Catholic',
                      'Sikh',
                      'Others',
                    ],
                  ),
                  _DropDownListItem(
                    ref: _ref,
                    field: 'race',
                    values: const [
                      'Chinese',
                      'Malay',
                      'Indian',
                      'Eurasian',
                      'Hispanic',
                      'Caucasian',
                      'African',
                      'Others',
                    ],
                  ),
                ],
              ),
            ),
            _TextFieldListItem(
              field: 'describeMyself',
              label: 'Describe Myself',
              icon: Icons.person_outline,
              ref: _ref,
            ),
            const Divider(),
            Text(
              'Education background',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _TextFieldListItem(
                    field: 'universityAttended',
                    label: 'University attended',
                    icon: Icons.account_balance,
                    ref: _ref,
                  ),
                  _TextFieldListItem(
                    field: 'coursesPursued',
                    label: 'Courses pursued',
                    icon: Icons.book,
                    ref: _ref,
                  ),
                  _TextFieldListItem(
                    field: 'highSchoolAttended',
                    label: 'High school attended',
                    icon: Icons.account_balance,
                    ref: _ref,
                  ),
                  _TextFieldListItem(
                    field: 'extracurricularsTaken',
                    label: 'Extracurriculars taken',
                    icon: Icons.golf_course,
                    ref: _ref,
                  ),
                  _TextFieldListItem(
                    field: 'leadershipPositions',
                    label: 'Leadership positions',
                    icon: Icons.people,
                    ref: _ref,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DropDownListItem extends StatelessWidget {
  final String field;
  final List<String> values;
  final DocumentReference ref;

  const _DropDownListItem({
    Key key,
    @required this.field,
    @required this.values,
    @required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DropDownButton(
          ref: ref,
          field: field,
          values: values,
        ),
        Opacity(
          opacity: 0.8,
          child: Text(field.toUpperCase()),
        ),
      ],
    );
  }
}

class _TextFieldListItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String field;
  final DocumentReference ref;

  const _TextFieldListItem({
    Key key,
    @required this.label,
    @required this.icon,
    @required this.field,
    @required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      title: _TextField(
        label: label,
        icon: icon,
        ref: ref,
        field: field,
      ),
    );
  }
}

class _DropDownButton extends StatelessWidget {
  final String field;
  final DocumentReference ref;
  final List<String> values;

  const _DropDownButton({
    Key key,
    @required this.field,
    @required this.ref,
    @required this.values,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        return DropdownButton(
          value: snapshot.data[field],
          onChanged: (value) {
            Firestore.instance.runTransaction((tx) async {
              await tx.update(ref, {
                field: value,
              });
            });
          },
          items: values
              .map(
                (el) => DropdownMenuItem(
                      value: el,
                      child: Text(el),
                    ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final DocumentReference ref;
  final String field;

  const _TextField({
    Key key,
    @required this.label,
    @required this.icon,
    @required this.ref,
    @required this.field,
  }) : super(key: key);

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
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
