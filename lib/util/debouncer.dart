import 'dart:async';
import 'dart:ui';

class Debouncer {
  Timer _timer;

  Debouncer();

  run(int ms, VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }
}
