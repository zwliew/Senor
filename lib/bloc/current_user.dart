import 'package:bloc/bloc.dart';

abstract class CurrentUserEvent {
  const CurrentUserEvent();
}

class LoggedIn extends CurrentUserEvent {
  final String id;

  const LoggedIn(this.id) : super();
}

class LoggedOut extends CurrentUserEvent {}

class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUser> {
  @override
  CurrentUser get initialState => CurrentUser(null);

  @override
  Stream<CurrentUser> mapEventToState(event) async* {
    if (event is LoggedIn) {
      yield CurrentUser(event.id);
    } else if (event is LoggedOut) {
      yield CurrentUser(null);
    }
  }
}

class CurrentUser {
  final String id;

  const CurrentUser(this.id);
}
