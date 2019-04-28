// Functions to parse data from Firestore safely

int parseUserCreationTimestamp(data) {
  return data['creationTimestamp'] ?? 0;
}

String parseUserDescription(data) {
  return data['describeMyself'] ?? '';
}

int parseUserReputation(data) {
  return data['reputation'] ?? 0;
}

String parseUserGender(data) {
  return data['gender'] ?? '';
}

String parseUserRace(data) {
  return data['race'] ?? '';
}

String parseUserReligion(data) {
  return data['religion'] ?? '';
}

String parseUserDisplayName(data) {
  return data['displayName'] ?? '';
}
