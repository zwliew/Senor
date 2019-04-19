// Functions to parse data from Firestore safely

parseUserCreationTimestamp(data) {
  return data['creationTimestamp'] ?? 0;
}

parseUserDescription(data) {
  return data['describeMyself'] ?? '';
}

parseUserReputation(data) {
  return data['reputation'] ?? 0;
}

parseUserGender(data) {
  return data['gender'] ?? '';
}

parseUserRace(data) {
  return data['race'] ?? '';
}

parseUserReligion(data) {
  return data['religion'] ?? '';
}

parseUserDisplayName(data) {
  return data['displayName'] ?? '';
}
