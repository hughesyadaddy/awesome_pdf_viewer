import 'dart:async';
import 'dart:ui';

/// A utility class that helps in debouncing multiple calls into one.
///
/// This is especially useful for events that fire rapidly (like typing)
/// to prevent multiple executions of a potentially heavy operation.
class Debouncer {
  /// Creates an instance of [Debouncer] with a specific delay.
  ///
  /// The [delay] determines how long to wait before executing the callback.
  Debouncer({required this.delay});

  /// The delay duration before the callback is executed.
  final Duration delay;

  Timer? _timer;

  /// Runs the provided callback after the specified delay. If this method is called
  /// again before the delay is over, the callback from the previous call will be cancelled
  /// and the delay will be reset.
  ///
  /// [callback] is the function that will be executed after the delay.
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancels the timer if it's active and prevents the callback from being executed.
  void cancel() {
    _timer?.cancel();
  }
}
