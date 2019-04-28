import 'dart:async';

import 'package:flutter/material.dart';
import 'package:senor/util/debouncer.dart';

class TextFieldListItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String field;
  final Function onChanged;
  final Stream stream;
  final String text;
  final int delayMs;

  const TextFieldListItem({
    Key key,
    @required this.label,
    @required this.icon,
    @required this.onChanged,
    this.stream,
    this.field,
    this.text,
    this.delayMs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      title: _TextField(
        label: label,
        icon: icon,
        field: field,
        onChanged: onChanged,
        stream: stream,
        text: text,
        delayMs: delayMs,
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String field;
  final Function onChanged;
  final Stream stream;
  final String text;
  final int delayMs;

  const _TextField({
    Key key,
    @required this.label,
    @required this.icon,
    @required this.onChanged,
    this.stream,
    this.field,
    this.text,
    this.delayMs,
  }) : super(key: key);

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  final _debouncer = Debouncer();

  int _lastEditedMs = 0;

  TextEditingController _controller;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.text);

    _subscription = widget.stream?.listen((snapshot) {
      setState(() {
        // Only update the TextEditingController when:
        // 1. The text was not changed by the user in the app
        // 2. The user is not currently editing the text
        if (_controller.text != snapshot.data[widget.field] &&
            (widget.delayMs == null ||
                DateTime.now().millisecondsSinceEpoch - _lastEditedMs >
                    widget.delayMs)) {
          _controller.text = snapshot.data[widget.field];
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        border: const OutlineInputBorder(),
        labelText: widget.label,
      ),
      controller: _controller,
      onChanged: (value) {
        _lastEditedMs = DateTime.now().millisecondsSinceEpoch;
        if (widget.delayMs == null) {
          widget.onChanged(value);
        } else {
          _debouncer.run(widget.delayMs, () => widget.onChanged(value));
        }
      },
    );
  }
}
