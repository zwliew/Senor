import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/profile_route.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';

class DiscoverPageSearchFilter {
  final String universityAttended;
  final String coursesPursued;

  const DiscoverPageSearchFilter({
    this.universityAttended = '',
    this.coursesPursued = '',
  });

  DiscoverPageSearchFilter copyWith({
    String universityAttended,
    String coursesPursued,
  }) {
    return DiscoverPageSearchFilter(
      universityAttended: universityAttended ?? this.universityAttended,
      coursesPursued: coursesPursued ?? this.coursesPursued,
    );
  }

  bool matches({
    String universityAttended = '',
    String coursesPursued = '',
  }) {
    return universityAttended
            .toLowerCase()
            .contains(this.universityAttended.toLowerCase()) &&
        coursesPursued
            .toLowerCase()
            .contains(this.coursesPursued.toLowerCase());
  }
}

class DiscoverPage extends StatelessWidget {
  final DiscoverPageSearchFilter filter;

  const DiscoverPage({
    Key key,
    @required this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Display active filters in DiscoverPage
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
                      filter.matches(
                        universityAttended: parseUserUniversityAttended(doc),
                        coursesPursued: parseUserCoursesPursued(doc),
                      ))
                  .toList();
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
}
