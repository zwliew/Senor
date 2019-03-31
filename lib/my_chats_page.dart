import 'package:flutter/material.dart';

class MyChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement the MyChatsPage
    return Opacity(
      opacity: 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.flight_land,
                size: 48.0,
              ),
            ),
            const Text('Arriving soon'),
          ],
        ),
      ),
    );
  }
}
