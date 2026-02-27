/// Counter States: The UI state of the counter
///
/// States represent what the UI should display:
/// - CounterInitial: Starting state
/// - CounterUpdated: Counter has a value, display it
/// - CounterLoading: An operation is in progress (though counter is so fast, we might not see it)
/// - CounterError: Something went wrong
///
/// The BLoC emits states
/// The UI listens to states and rebuilds accordingly
abstract class CounterState {
  const CounterState();
}

/// Initial state before any interaction
/// The UI should show 0 or a loading indicator
class CounterInitial extends CounterState {
  const CounterInitial();
}

/// The counter has a value ready to display
/// The UI should show this value
class CounterUpdated extends CounterState {
  final int value;

  /// Constructor: Holds the current counter value
  /// This is what the UI displays
  const CounterUpdated(this.value);
}

/// An operation is in progress (increment, decrement, reset)
/// The UI might show a loading spinner
/// (Though for a counter, this will be so fast you probably won't see it)
class CounterLoading extends CounterState {
  const CounterLoading();
}

/// Something went wrong
/// The UI should show an error message
class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);
}
