import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/chat_page.dart';
import 'package:senor/singletons.dart';
import 'package:senor/ui/loading_indicator.dart';

class MyChatsPage extends StatelessWidget {
  const MyChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserEvent, CurrentUser>(
      bloc: BlocProvider.of<CurrentUserBloc>(context),
      builder: (context, curUser) => StreamBuilder(
            stream: Firestore.instance
                .collection('chats')
                .where('recipients.${curUser.id}', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingIndicator();
              }

              final docs = snapshot.data.documents;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final recipientId = doc['recipients']
                      .keys
                      .firstWhere((el) => el != curUser.id);
                  return ListTile(
                    title: Text(recipientId),
                    onTap: () {
                      Analytics.analytics.setCurrentScreen(
                        screenName: 'chat',
                        screenClassOverride: 'ChatPage',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                                chatId: doc.documentID,
                                recipientId: recipientId,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
    );
  }
}
