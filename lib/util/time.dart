int curMs() {
  final now = DateTime.now();
  return now.millisecondsSinceEpoch;
}

DateTime dateFromMs(ms) {
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}
