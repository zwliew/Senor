buildProfileDateString(ms) {
  final date = DateTime.fromMillisecondsSinceEpoch(
    ms,
    isUtc: true,
  );
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
