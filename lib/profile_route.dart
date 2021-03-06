import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/chat_page.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/profile_tidbit.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/database.dart';
import 'package:senor/util/profile.dart';

navigateToProfile({
  @required String profileId,
  @required BuildContext context,
}) {
  Analytics.analytics.setCurrentScreen(
    screenName: 'profile',
    screenClassOverride: 'ProfileRoute',
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ProfileRoute(profileId: profileId),
    ),
  );
}

class _ProfileRoute extends StatelessWidget {
  final String profileId;

  const _ProfileRoute({
    Key key,
    @required this.profileId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _ProfileRouteDetails(profileId: profileId),
        ),
      ),
    );
  }
}

class _ProfileRouteDetails extends StatelessWidget {
  final String profileId;

  const _ProfileRouteDetails({
    Key key,
    @required this.profileId,
  }) : super(key: key);

  _contactUser({
    @required BuildContext context,
    @required String myId,
    @required String otherId,
  }) async {
    // TODO: Add an alternative method of contacting a user
    // This could be a built-in messaging platform,
    // or a user-defined mode of communication.
    // Examples include WhatsApp, Facebook, Instagram.
    final snapshot = await Firestore.instance
        .collection('chats')
        .where('recipients.$myId', isEqualTo: true)
        .where('recipients.$otherId', isEqualTo: true)
        .getDocuments();
    String chatId;
    if (snapshot.documents.length == 0) {
      final ref = Firestore.instance.collection('chats').document();
      chatId = ref.documentID;
      ref.setData({
        'recipients': {
          myId: true,
          otherId: true,
        }
      });
    } else {
      chatId = snapshot.documents[0].documentID;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
              chatId: chatId,
              recipientId: otherId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.document('users/$profileId').snapshots(),
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
                photoUrl: parseUserPhotoUrl(data),
                displayName: parseUserDisplayName(data),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    parseUserDisplayName(data),
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Text(
                    parseUserDescription(data),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileTidbit(
                    data: parseUserGender(data),
                    desc: 'GENDER',
                  ),
                  ProfileTidbit(
                    data: parseUserRace(data),
                    desc: 'RACE',
                  ),
                  ProfileTidbit(
                    data: parseUserReligion(data),
                    desc: 'RELIGION',
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<CurrentUserEvent, CurrentUser>(
                bloc: BlocProvider.of<CurrentUserBloc>(context),
                builder: (context, curUser) => RaisedButton(
                      onPressed: () => _contactUser(
                            context: context,
                            otherId: profileId,
                            myId: curUser.id,
                          ),
                      child: const Text('Contact Me'),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
