import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/profile_route.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  .where((doc) => doc.documentID != curUser.id)
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
