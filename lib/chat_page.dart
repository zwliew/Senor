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
    return Scaffold(
      appBar: AppBar(
        title: Text(recipient),
      ),
      body: StreamBuilder(
        stream:
            Firestore.instance.collection('chats/$chatId/messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final docs = snapshot.data.documents;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(doc['text']),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Expanded(child: TextField()),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
