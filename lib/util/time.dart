import 'package:timeago/timeago.dart' as timeago;

int curMs() {
  final now = DateTime.now();
  return now.millisecondsSinceEpoch;
}

DateTime dateFromMs(int ms, {bool isUtc = true}) {
  return DateTime.fromMillisecondsSinceEpoch(
    ms,
    isUtc: isUtc,
  );
}

String fuzzyDateString(int ms) {
  final prevDate = dateFromMs(ms);
  return timeago.format(prevDate);
}

String readableDateString(int ms) {
  final dateString = dateFromMs(
    ms,
    isUtc: false,
  ).toString();
  // Remove seconds and milliseconds from the date String
  return dateString.substring(0, dateString.length - 7);
}
