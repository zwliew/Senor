import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String fromUid, toUid, toDisplayName;

  const ChatPage({
    Key key,
    @required this.fromUid,
    @required this.toUid,
    @required this.toDisplayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(toDisplayName),
      ),
      body: ListView(),
    );
  }
}
