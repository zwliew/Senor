import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  String _uid;

  UserModel({String uid}) {
    _uid ??= uid;
  }

  String get uid => _uid;

  setUser({String uid}) {
    _uid ??= uid;

    notifyListeners();
  }

  clear() {
    _uid = null;

    notifyListeners();
  }
}
