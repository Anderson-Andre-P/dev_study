import '../entities/timer_value.dart';

/// TimerRepository: Interface for timer operations
///
/// This defines what a timer can do:
/// - Start: Begin the countdown
/// - Pause: Temporarily stop it
/// - Resume: Continue from where it paused
/// - Stop: Cancel it completely
/// - Get ticks: Stream of timer updates (every second)
///
/// Key difference from counter:
/// Counter operations happen instantly
/// Timer operations happen over time (returns Stream, not just Future)
abstract class TimerRepository {
  /// Start a new timer with the given duration in seconds
  /// Returns the initial timer value
  Future<TimerValue> startTimer(int durationInSeconds);

  /// Pause the timer
  /// Returns the paused timer value
  Future<TimerValue> pauseTimer();

  /// Resume a paused timer
  /// Returns the resumed timer value
  Future<TimerValue> resumeTimer();

  /// Stop the timer completely
  /// Returns a finished timer (0 seconds)
  Future<TimerValue> stopTimer();

  /// Get a stream of timer ticks
  /// Every time the timer updates (each second), this stream emits a new TimerValue
  ///
  /// Stream vs Future:
  /// - Future: Resolves once with a single value
  /// - Stream: Emits multiple values over time
  ///
  /// Timer needs Stream because:
  /// - Timer emits new value every second
  /// - Multiple emissions over time
  /// - Not just one value at the end
  Stream<TimerValue> getTimerTicks();

  /// Reset the timer to zero and stop
  /// Useful for cleanup when user navigates away
  Future<void> resetTimer();
}
