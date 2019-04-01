import 'package:flutter/material.dart';

class ProfileTidbit extends StatelessWidget {
  final String data;
  final String desc;

  const ProfileTidbit({
    Key key,
    @required this.data,
    @required this.desc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data,
          style: Theme.of(context).textTheme.body2,
        ),
        Text(
          desc,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
