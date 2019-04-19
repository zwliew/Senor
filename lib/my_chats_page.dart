import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senor/chat_page.dart';
import 'package:senor/ui/loading_indicator.dart';

class MyChatsPage extends StatelessWidget {
  final String uid;

  const MyChatsPage({
    Key key,
    @required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('chats')
          .where('recipients.$uid', isEqualTo: true)
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
            final recipient =
                doc['recipients'].keys.firstWhere((el) => el != uid);
            return ListTile(
              title: Text(recipient),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                          chatId: doc.documentID,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
