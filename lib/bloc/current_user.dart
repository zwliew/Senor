import 'package:bloc/bloc.dart';

abstract class CurrentUserEvent {
  const CurrentUserEvent();
}

class LoggedIn extends CurrentUserEvent {
  final String uid;

  const LoggedIn(this.uid) : super();
}

class LoggedOut extends CurrentUserEvent {}

class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUser> {
  @override
  CurrentUser get initialState => CurrentUser(null);

  @override
  Stream<CurrentUser> mapEventToState(event) async* {
    if (event is LoggedIn) {
      yield CurrentUser(event.uid);
    } else if (event is LoggedOut) {
      yield CurrentUser(null);
    }
  }
}

class CurrentUser {
  final String uid;

  const CurrentUser(this.uid);
}
