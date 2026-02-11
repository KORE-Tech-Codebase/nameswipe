import 'dart:async';

class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  /// Runs [action] after [duration] has elapsed without another call.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a pending action exists.
  bool get isActive => _timer?.isActive ?? false;

  /// Disposes of the debouncer.
  void dispose() {
    cancel();
  }
}

class Throttler {
  Throttler({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  /// Runs [action] immediately, then ignores subsequent calls for [duration].
  void run(void Function() action) {
    if (_isThrottled) return;
    action();
    _isThrottled = true;
    _timer?.cancel();
    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }

  void dispose() {
    cancel();
  }
}
