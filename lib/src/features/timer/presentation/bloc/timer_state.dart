import '../../domain/entities/timer_value.dart';

/// Timer States: The UI state of the timer
///
/// These describe what the UI should show:
abstract class TimerState {
  const TimerState();
}

/// Initial state: No timer set yet
/// User should see input field asking for duration
class TimerInitial extends TimerState {
  const TimerInitial();
}

/// Timer is waiting for user input
/// Shows the input form
class TimerInputState extends TimerState {
  const TimerInputState();
}

/// Timer is running
/// Shows countdown, pause button, stop button
class TimerRunning extends TimerState {
  final TimerValue timerValue;

  const TimerRunning(this.timerValue);
}

/// Timer is paused
/// Shows remaining time, resume button, stop button
class TimerPaused extends TimerState {
  final TimerValue timerValue;

  const TimerPaused(this.timerValue);
}

/// Timer finished!
/// Shows "00:00" and a completion message
/// User can start a new timer
class TimerFinished extends TimerState {
  final TimerValue timerValue;

  const TimerFinished(this.timerValue);
}

/// An error occurred
/// Shows error message and allows retry
class TimerError extends TimerState {
  final String message;

  const TimerError(this.message);
}
