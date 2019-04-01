import 'package:flutter/material.dart';

buildProfileDateString(ms) {
  final date = DateTime.fromMillisecondsSinceEpoch(
    ms,
    isUtc: true,
  );
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

buildProfileTidbitWidget({@required String data, @required String desc}) {
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
