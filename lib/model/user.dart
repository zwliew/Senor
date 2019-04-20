import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  String _uid;
  String _displayName;
  String _photoUrl;

  UserModel({String uid, String displayName, String photoUrl}) {
    _uid ??= uid;
    _displayName ??= displayName;
    _photoUrl ??= photoUrl;
  }

  String get uid => _uid;
  String get displayName => _displayName;
  String get photoUrl => _photoUrl;

  setUser({String uid, String displayName, String photoUrl}) {
    _uid ??= uid;
    _displayName ??= displayName;
    _photoUrl ??= photoUrl;

    notifyListeners();
  }

  clear() {
    _uid = null;
    _displayName = null;
    _photoUrl = null;

    notifyListeners();
  }
}
