import 'package:flutter/material.dart';

class UserIcon extends StatelessWidget {
  final String displayName;
  final String photoUrl;
  final double radius;

  const UserIcon({
    Key key,
    this.displayName,
    this.photoUrl,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display the user's photo if available
    if (photoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    // Otherwise, display the user's initials with a random BG color
    if (displayName != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).accentColor,
        child: Text(displayName
            .split(' ')
            .take(2)
            .map((s) => s.substring(0, 1))
            .join('')
            .toUpperCase()),
      );
    }

    // Else, display a smiley face with a random BG color
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).accentColor,
      child: const Text(':D'),
    );
  }
}
