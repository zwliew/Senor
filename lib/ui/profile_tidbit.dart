import 'package:flutter/widgets.dart';

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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Opacity(
          opacity: 0.8,
          child: Text(desc),
        ),
      ],
    );
  }
}
