import 'package:senor/util/time.dart';

buildProfileDateString(ms) {
  final date = dateFromMs(ms);
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

class ProfileLabel {
  static const universityAttended = 'University attended';
  static const coursesPursured = 'Courses pursued';
  static const highSchoolAttended = 'High school attended';
  static const extracurricularsTaken = 'Extracurriculars taken';
  static const leadershipPositions = 'Leadership positions';
}
