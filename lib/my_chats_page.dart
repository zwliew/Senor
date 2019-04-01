import 'package:flutter/material.dart';

class MyChatsPage extends StatelessWidget {
  const MyChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the MyChatsPage
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.flight_land,
              size: 48.0,
            ),
          ),
          Text(
            'Arriving soon',
            style: Theme.of(context).textTheme.body2,
          ),
        ],
      ),
    );
  }
}
