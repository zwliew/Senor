import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserIcon(displayName: doc['from']),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['from'],
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                                if (doc['imageUrl'] != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: doc['imageUrl'] == 'loading'
                                        ? const CircularProgressIndicator()
                                        : CachedNetworkImage(
                                            imageUrl: doc['imageUrl'],
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            width: 240.0,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                Text(doc['text']),
                              ],
                            ),
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
                        onSubmit: ({String text, File imageFile}) async {
                          // TODO: Refactor all this logic into a Cloud Function
                          final ref = Firestore.instance
                              .collection('chats/$chatId/messages')
                              .document();

                          ref.setData({
                            if (imageFile != null) 'imageUrl': 'loading',
                            'text': text,
                            'from': curUser.id,
                            'sentTimestamp': curMs(),
                          });

                          if (imageFile != null) {
                            final fileRef = FirebaseStorage.instance
                                .ref()
                                .child(curMs().toString());
                            final task = fileRef.putFile(imageFile);
                            final snapshot = await task.onComplete;
                            final url = await snapshot.ref.getDownloadURL();
                            ref.updateData({
                              'imageUrl': url,
                            });
                          }
                        },
                        emptyError: 'Please enter a message.',
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

  File _imageFile;

  bool _isComposing() {
    return _controller.text.trim().length > 0 || _imageFile != null;
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          IconButton(
            icon: _imageFile != null
                ? Image.file(
                    _imageFile,
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image),
            onPressed: () async {
              final image = await ImagePicker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setState(() {
                  _imageFile = image;
                });
              }
            },
          ),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type a message',
              ),
              controller: _controller,
              validator: (value) {
                if (value.isEmpty && _imageFile == null) {
                  return widget.emptyError;
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _isComposing()
                ? () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }

                    widget.onSubmit(
                      text: _controller.text,
                      imageFile: _imageFile,
                    );
                    _imageFile = null;
                    _controller.clear();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
