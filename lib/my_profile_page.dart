import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/debouncer.dart';
import 'package:senor/util/profile.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _MyProfilePageDetails(),
      ),
    );
  }
}

class _MyProfilePageDetails extends StatefulWidget {
  @override
  _MyProfilePageDetailsState createState() => _MyProfilePageDetailsState();
}

class _MyProfilePageDetailsState extends State<_MyProfilePageDetails> {
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

  _buildDropDownWidget({String field, List<String> values}) {
    return Column(
      children: [
        MyProfileDropDownButton(
          ref: _ref,
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
                  _buildDropDownWidget(
                    field: 'gender',
                    values: const [
                      'Male',
                      'Female',
                      'Others',
                    ],
                  ),
                  _buildDropDownWidget(
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
                  _buildDropDownWidget(
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
            _buildTextFieldWidget(
              field: 'describeMyself',
              label: 'Describe Myself',
              icon: Icons.person_outline,
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
                  _buildTextFieldWidget(
                    field: 'universityAttended',
                    label: 'University attended',
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
            ),
          ],
        );
      },
    );
  }
}

class MyProfileDropDownButton extends StatelessWidget {
  final String field;
  final DocumentReference ref;
  final List<String> values;

  const MyProfileDropDownButton({
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
