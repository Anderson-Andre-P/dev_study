/// TimerValue Entity: Represents the state of a timer
///
/// This entity holds everything about a timer:
/// - remainingSeconds: How many seconds left
/// - totalSeconds: The original duration
/// - isRunning: Is the timer currently counting down?
///
/// Why store both remaining and total?
/// - remainingSeconds: What the UI shows (00:45)
/// - totalSeconds: Useful for progress calculations
/// - isRunning: Know if we're actively counting
///
/// Example:
/// User sets timer for 60 seconds
/// After 15 seconds: TimerValue(remainingSeconds: 45, totalSeconds: 60, isRunning: true)
/// User stops it: TimerValue(remainingSeconds: 45, totalSeconds: 60, isRunning: false)
/// Timer finishes: TimerValue(remainingSeconds: 0, totalSeconds: 60, isRunning: false)
class TimerValue {
  /// How many seconds are left in the countdown
  final int remainingSeconds;

  /// The total duration the user set (for calculating progress)
  final int totalSeconds;

  /// Is the timer currently running?
  /// true = counting down
  /// false = paused or finished
  final bool isRunning;

  const TimerValue({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
  });

  /// Helper: Is the timer finished?
  bool get isFinished => remainingSeconds == 0;

  /// Helper: Calculate progress (0.0 to 1.0)
  /// Useful for progress bars
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  /// Helper: Format as MM:SS for display
  /// Example: 65 seconds → "01:05"
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
