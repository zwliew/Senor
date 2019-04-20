import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:senor/chat_page.dart';
import 'package:senor/model/user.dart';
import 'package:senor/ui/loading_indicator.dart';

class MyChatsPage extends StatelessWidget {
  const MyChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, curUser) => StreamBuilder(
            stream: Firestore.instance
                .collection('chats')
                .where('recipients.${curUser.uid}', isEqualTo: true)
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
                  final recipient = doc['recipients']
                      .keys
                      .firstWhere((el) => el != curUser.uid);
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
          ),
    );
  }
}
