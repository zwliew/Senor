import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senor/app.dart';
import 'package:senor/bloc/current_user.dart';

void main() {
  final curUserBloc = CurrentUserBloc();
  runApp(
    BlocProvider<CurrentUserBloc>(
      bloc: curUserBloc,
      child: const App(),
    ),
  );
}
