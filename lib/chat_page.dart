import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senor/ui/loading_indicator.dart';

class ChatPage extends StatelessWidget {
  final String chatId, recipient;

  const ChatPage({
    Key key,
    @required this.chatId,
    @required this.recipient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.document('chats/$chatId').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final data = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(recipient),
            ),
            // TODO
            body: Container(),
          );
        });
  }
}
