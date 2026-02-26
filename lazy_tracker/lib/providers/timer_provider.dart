import 'dart:async';
import 'package:flutter/foundation.dart';

enum TimerState { stopped, running, paused }

class TimerProvider with ChangeNotifier {
  int _secondsElapsed = 0;
  TimerState _currentState = TimerState.stopped;
  Timer? _timer;

  int get secondsElapsed => _secondsElapsed;
  TimerState get currentState => _currentState;

  String get formattedTime {
    int hours = _secondsElapsed ~/ 3600;
    int minutes = (_secondsElapsed % 3600) ~/ 60;
    int seconds = _secondsElapsed % 60;

    String hrs = hours.toString().padLeft(2, '0');
    String mins = minutes.toString().padLeft(2, '0');
    String secs = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hrs:$mins:$secs';
    }
    return '$mins:$secs';
  }

  void start() {
    if (_currentState == TimerState.running) return;

    _currentState = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _currentState = TimerState.paused;
    notifyListeners();
  }

  void toggle() {
    if (_currentState == TimerState.running) {
      pause();
    } else {
      start();
    }
  }

  double finishAndGetHours() {
    _timer?.cancel();
    _currentState = TimerState.stopped;

    // Calculate hours (e.g. 90 mins = 1.5 hours)
    double hours = _secondsElapsed / 3600.0;

    // Reset timer
    _secondsElapsed = 0;
    notifyListeners();

    return hours;
  }
}
