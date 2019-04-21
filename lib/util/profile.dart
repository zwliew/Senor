import 'package:senor/util/time.dart';

buildProfileDateString(ms) {
  final date = dateFromMs(ms);
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
