import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/bloc/current_user.dart';
import 'package:senor/ui/loading_indicator.dart';
import 'package:senor/ui/user_icon.dart';
import 'package:senor/util/time.dart';

class ChatPage extends StatelessWidget {
  final String chatId, recipientId;

  const ChatPage({
    Key key,
    @required this.chatId,
    @required this.recipientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipientId),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('chats/$chatId/messages')
            .orderBy('sentTimestamp', descending: true)
            .snapshots(),
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
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: UserIcon(displayName: recipientId),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipientId,
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(doc['text']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: BlocBuilder<CurrentUserEvent, CurrentUser>(
                  bloc: BlocProvider.of<CurrentUserBloc>(context),
                  builder: (context, curUser) => _TextFieldForm(
                        onSubmit: (text) {
                          final ref = Firestore.instance
                              .collection('chats/$chatId/messages')
                              .document();
                          ref.setData({
                            'text': text,
                            'from': curUser.id,
                            'sentTimestamp': curMs(),
                          });
                        },
                        emptyError: 'Please enter your message.',
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextFieldForm extends StatefulWidget {
  final Function onSubmit;
  final String emptyError;

  const _TextFieldForm({
    Key key,
    @required this.onSubmit,
    @required this.emptyError,
  }) : super(key: key);

  @override
  _TextFieldFormState createState() => _TextFieldFormState();
}

class _TextFieldFormState extends State<_TextFieldForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              validator: (value) {
                if (value.isEmpty) {
                  return widget.emptyError;
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.onSubmit(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
