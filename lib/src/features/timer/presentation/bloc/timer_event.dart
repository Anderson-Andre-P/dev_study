/// Timer Events: User actions and system events
///
/// These represent everything that can happen in the timer:
/// - User taps "Start" button
/// - User taps "Pause" button
/// - Timer emits a tick (internal system event)
/// - Timer finishes naturally
abstract class TimerEvent {
  const TimerEvent();
}

/// User entered a duration and tapped "Start"
/// The duration is in seconds
class TimerStarted extends TimerEvent {
  final int durationInSeconds;

  const TimerStarted(this.durationInSeconds);
}

/// User tapped "Pause" button
/// Timer stops but time is preserved
class TimerPaused extends TimerEvent {
  const TimerPaused();
}

/// User tapped "Resume" button (when paused)
/// Timer continues from where it paused
class TimerResumed extends TimerEvent {
  const TimerResumed();
}

/// User tapped "Stop" button
/// Timer resets to 0
class TimerStopped extends TimerEvent {
  const TimerStopped();
}

/// Timer emitted a tick
/// This happens every second while timer is running
/// Sent by the BLoC itself when listening to the stream
class TimerTicked extends TimerEvent {
  final int remainingSeconds;

  const TimerTicked(this.remainingSeconds);
}

/// Timer finished naturally (reached 0)
/// Internal event sent when countdown completes
class TimerFinished extends TimerEvent {
  const TimerFinished();
}

/// An error occurred in the timer stream
/// Emitted when the timer stream throws an error
class TimerErrorOccurred extends TimerEvent {
  final String message;

  const TimerErrorOccurred(this.message);
}
