import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String chatId;

  const ChatPage({
    Key key,
    @required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
      ),
      // TODO
      body: Container(),
    );
  }
}
