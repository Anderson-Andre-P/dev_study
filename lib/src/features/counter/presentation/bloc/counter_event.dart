/// Counter Events: User actions on the counter
///
/// Events represent what the user does:
/// - User taps "+" button → CounterIncremented event
/// - User taps "-" button → CounterDecremented event
/// - User taps "Reset" button → CounterReset event
///
/// The UI sends events to the BLoC
/// The BLoC processes them and emits new states
abstract class CounterEvent {
  const CounterEvent();
}

/// User pressed the increment button
/// "Please add 1 to the counter"
class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

/// User pressed the decrement button
/// "Please subtract 1 from the counter"
class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}

/// User pressed the reset button
/// "Please set the counter to zero"
class CounterReset extends CounterEvent {
  const CounterReset();
}
