import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/profile_tidbit.dart';
import 'package:senor/ui/text_field_list_item.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';
import 'package:senor/util/profile.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: const Padding(
        padding: const EdgeInsets.all(8.0),
        child: const _PageDetails(),
      ),
    );
  }
}

class _PageDetails extends StatelessWidget {
  static const _describeMyselfField = 'describeMyself';
  static const _universityAttendedField = 'universityAttended';
  static const _coursesPursuedField = 'coursesPursued';
  static const _highSchoolAttendedField = 'highSchoolAttended';
  static const _extracurricularsTakenField = 'extracurricularsTaken';
  static const _leadershipPositionsField = 'leadershipPositions';

  // Delay in milliseconds after a text change to be sure
  // that the user is not currently typing
  static const _textEditDelayMs = 750;

  const _PageDetails({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserEvent, CurrentUser>(
      bloc: BlocProvider.of<CurrentUserBloc>(context),
      builder: (context, curUser) {
        final DocumentReference ref =
            Firestore.instance.document('users/${curUser.id}');
        return StreamBuilder(
          stream: ref.snapshots(),
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
                  child: Text(
                    parseUserDisplayName(data),
                    style: Theme.of(context).textTheme.headline,
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
                const Divider(),
                Text(
                  'About myself',
                  style: Theme.of(context).textTheme.body2.apply(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DropDownListItem(
                        ref: ref,
                        field: 'gender',
                        values: const [
                          'Male',
                          'Female',
                          'Others',
                        ],
                      ),
                      _DropDownListItem(
                        ref: ref,
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
                        ref: ref,
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
                TextFieldListItem(
                  label: 'Describe Myself',
                  icon: Icons.person_outline,
                  onChanged: (value) {
                    ref.updateData({
                      _describeMyselfField: value.trim(),
                    });
                  },
                  stream: ref.snapshots(),
                  field: _describeMyselfField,
                  delayMs: _textEditDelayMs,
                ),
                const Divider(),
                Text(
                  'Education background',
                  style: Theme.of(context).textTheme.body2.apply(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      TextFieldListItem(
                        label: ProfileLabel.universityAttended,
                        icon: Icons.account_balance,
                        onChanged: (value) {
                          ref.updateData({
                            _universityAttendedField: value.trim(),
                          });
                        },
                        stream: ref.snapshots(),
                        field: _universityAttendedField,
                        delayMs: _textEditDelayMs,
                      ),
                      TextFieldListItem(
                        label: ProfileLabel.coursesPursured,
                        icon: Icons.book,
                        onChanged: (value) {
                          ref.updateData({
                            _coursesPursuedField: value.trim(),
                          });
                        },
                        stream: ref.snapshots(),
                        field: _coursesPursuedField,
                        delayMs: _textEditDelayMs,
                      ),
                      TextFieldListItem(
                        label: ProfileLabel.highSchoolAttended,
                        icon: Icons.account_balance,
                        onChanged: (value) {
                          ref.updateData({
                            _highSchoolAttendedField: value.trim(),
                          });
                        },
                        stream: ref.snapshots(),
                        field: _highSchoolAttendedField,
                        delayMs: _textEditDelayMs,
                      ),
                      TextFieldListItem(
                        label: ProfileLabel.extracurricularsTaken,
                        icon: Icons.golf_course,
                        onChanged: (value) {
                          ref.updateData({
                            _extracurricularsTakenField: value.trim(),
                          });
                        },
                        stream: ref.snapshots(),
                        field: _extracurricularsTakenField,
                        delayMs: _textEditDelayMs,
                      ),
                      TextFieldListItem(
                        label: ProfileLabel.leadershipPositions,
                        icon: Icons.people,
                        onChanged: (value) {
                          ref.updateData({
                            _leadershipPositionsField: value.trim(),
                          });
                        },
                        stream: ref.snapshots(),
                        field: _leadershipPositionsField,
                        delayMs: _textEditDelayMs,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
        Text(
          field.toUpperCase(),
          style: Theme.of(context).textTheme.caption,
        ),
      ],
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
