import 'dart:async';

import '../../domain/entities/timer_value.dart';

/// TimerDataSource: Manages the actual countdown timer
///
/// This is more complex than previous datasources because:
/// - It manages a periodic operation (timer tick every second)
/// - It needs to keep state across multiple calls
/// - It uses streams to emit updates over time
///
/// Key difference from counter:
/// Counter: Simple variable storage
/// Timer: Active operation that emits values every second
class TimerDataSource {
  /// The actual timer that counts down
  /// null = no timer running
  /// non-null = timer is active
  Timer? _timer;

  /// Track remaining seconds
  /// Updates as timer counts down
  int _remainingSeconds = 0;

  /// Track total duration (for reset)
  int _totalSeconds = 0;

  /// Track if timer is running
  /// true = actively counting down
  /// false = paused or not started
  bool _isRunning = false;

  /// StreamController to emit timer updates
  /// This allows multiple listeners to receive timer ticks
  ///
  /// Why StreamController?
  /// - Timer needs to emit value every second
  /// - Multiple places might listen (UI, analytics, notifications)
  /// - StreamController handles broadcasting to all listeners
  final StreamController<TimerValue> _timerController =
      StreamController<TimerValue>.broadcast();

  /// Get the stream of timer updates
  /// Listeners subscribe to this stream
  /// They receive new TimerValue every second
  Stream<TimerValue> get timerStream => _timerController.stream;

  /// Start a new timer
  Future<TimerValue> startTimer(int durationInSeconds) async {
    // Stop any existing timer
    _cancelTimer();

    // Initialize
    _totalSeconds = durationInSeconds;
    _remainingSeconds = durationInSeconds;
    _isRunning = true;

    // Create a periodic timer that ticks every second
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        // Decrement the counter
        _remainingSeconds--;

        // Emit the updated value
        final timerValue = TimerValue(
          remainingSeconds: _remainingSeconds,
          totalSeconds: _totalSeconds,
          isRunning: _isRunning,
        );
        _timerController.add(timerValue);

        // Check if timer finished
        if (_remainingSeconds <= 0) {
          _isRunning = false;
          _cancelTimer();
        }
      },
    );

    // Return initial value
    return TimerValue(
      remainingSeconds: _remainingSeconds,
      totalSeconds: _totalSeconds,
      isRunning: _isRunning,
    );
  }

  /// Pause the timer
  /// Timer stops but doesn't reset
  Future<TimerValue> pauseTimer() async {
    _isRunning = false;
    _timer?.cancel();

    return TimerValue(
      remainingSeconds: _remainingSeconds,
      totalSeconds: _totalSeconds,
      isRunning: _isRunning,
    );
  }

  /// Resume a paused timer
  /// Continues counting down from where it paused
  Future<TimerValue> resumeTimer() async {
    if (_remainingSeconds > 0) {
      _isRunning = true;

      // Restart the periodic timer
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          _remainingSeconds--;

          final timerValue = TimerValue(
            remainingSeconds: _remainingSeconds,
            totalSeconds: _totalSeconds,
            isRunning: _isRunning,
          );
          _timerController.add(timerValue);

          if (_remainingSeconds <= 0) {
            _isRunning = false;
            _cancelTimer();
          }
        },
      );
    }

    return TimerValue(
      remainingSeconds: _remainingSeconds,
      totalSeconds: _totalSeconds,
      isRunning: _isRunning,
    );
  }

  /// Stop the timer
  /// Resets to 0 and stops
  Future<TimerValue> stopTimer() async {
    _cancelTimer();
    _remainingSeconds = 0;
    _isRunning = false;

    return TimerValue(
      remainingSeconds: 0,
      totalSeconds: _totalSeconds,
      isRunning: false,
    );
  }

  /// Cleanup: Cancel the timer and close the stream
  /// Call this when navigating away from timer screen
  Future<void> resetTimer() async {
    _cancelTimer();
    _remainingSeconds = 0;
    _totalSeconds = 0;
    _isRunning = false;
  }

  /// Private helper: Cancel the active timer
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cleanup when done
  void dispose() {
    _cancelTimer();
    _timerController.close();
  }
}
