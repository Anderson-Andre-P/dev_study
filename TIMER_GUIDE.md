# Timer: Stream Management & Long-Running Operations Learning Guide

## Overview

The **Timer** feature is an advanced example of the **BLoC state management pattern** combined with **Dart streams** for handling long-running, asynchronous operations.

It demonstrates how to manage a continuous countdown timer using the same clean architecture as the Counter, but with the added complexity of streams, periodic operations, and state transitions.

This guide explains every concept in detail, emphasizing the key differences from the simple Counter pattern.

---

## What is the Timer?

A countdown timer app that:
- Accepts a duration in seconds (user input)
- Counts down every second
- Can be paused and resumed
- Can be stopped completely
- Shows remaining time and progress
- Emits a completion signal when finished

**Key difference from Counter:**
- Counter: Discrete operations (increment, decrement, reset)
- Timer: Continuous operation (emits values every second over time)

---

## Why Timer is More Complex Than Counter

### Counter Pattern
```
User taps button → Event sent → Usecase called → Value changes → UI updates
(Single action, instant result)
```

### Timer Pattern
```
User taps start → Event sent → Timer starts → Emits tick every second → UI updates
                                              → Tick stream continues for N seconds
                                              → Timer finishes → Final state
(Single action, continuous results over time)
```

**New challenges:**
1. **Streams**: Timer emits multiple values over time (not just one)
2. **State transitions**: Idle → Running → Paused → Running → Finished
3. **Resource cleanup**: Timer and stream must be properly cancelled
4. **Time management**: Keep track of remaining time across state changes

---

## The 4-Layer Architecture (Extended)

### Layer 1: Domain (Business Logic)

**Files:**
- `entities/timer_value.dart` - What a timer state is
- `repositories/timer_repository.dart` - What operations we can do
- `usecases/start_timer.dart`, `pause_timer.dart`, etc. - How to perform each operation

**Key Point:** This layer defines the timer's behavior:

```
TimerValue entity:
  - remainingSeconds: How many seconds left
  - totalSeconds: Total duration (for progress)
  - isRunning: Is timer actively counting?

TimerRepository interface:
  - startTimer(duration): Begin countdown
  - pauseTimer(): Temporarily stop
  - resumeTimer(): Continue from pause
  - stopTimer(): Cancel completely
  - getTimerTicks(): Stream of updates every second
  - resetTimer(): Cleanup

UseCases:
  - StartTimer: Encapsulate "start a countdown"
  - PauseTimer: Encapsulate "pause it"
  - ResumeTimer: Encapsulate "continue"
  - StopTimer: Encapsulate "cancel it"
```

**New concept: Streams vs Futures**

```dart
// Counter (returns single value)
Future<Counter> increment()  // One value at the end

// Timer (returns many values over time)
Stream<TimerValue> getTimerTicks()  // New value every second
```

---

### Layer 2: Data (Timer Implementation)

**Files:**
- `datasources/timer_datasource.dart` - The actual timer mechanism
- `repositories/timer_repository_impl.dart` - Transforms data to entities

**Key Components in TimerDataSource:**

```dart
// 1. The actual Dart Timer object
Timer? _timer;

// 2. Track internal state
int _remainingSeconds = 0;
int _totalSeconds = 0;
bool _isRunning = false;

// 3. Stream controller to emit updates
final StreamController<TimerValue> _timerController =
  StreamController<TimerValue>.broadcast();
```

**What it does:**

```
User starts timer (60 seconds)
    ↓
Create Timer.periodic() that ticks every 1 second
    ↓
Every tick:
  - Decrement remaining seconds (60 → 59)
  - Create TimerValue with new remaining seconds
  - Emit via stream controller
  - Check if finished (remainingSeconds <= 0)
    ↓
    If finished: Cancel timer, stop emitting
    ↓
Return stream so listeners receive updates
```

**Key Methods:**

```dart
// Start: Create periodic timer and begin emitting
Future<TimerValue> startTimer(int durationInSeconds)

// Pause: Stop the timer, keep state
Future<TimerValue> pauseTimer()

// Resume: Restart timer from where it paused
Future<TimerValue> resumeTimer()

// Stop: Cancel everything, reset to 0
Future<TimerValue> stopTimer()

// Get stream: Return the stream of updates
Stream<TimerValue> get timerStream => _timerController.stream

// Reset: Cleanup when navigating away
Future<void> resetTimer()
```

---

### Layer 3: Presentation - BLoC (State Management)

**Files:**
- `bloc/timer_event.dart` - User actions + system events
- `bloc/timer_state.dart` - What the UI should show
- `bloc/timer_bloc.dart` - The orchestrator

**Key Events:**

```dart
TimerStarted(durationInSeconds)   // User tapped "Start"
TimerPaused()                      // User tapped "Pause"
TimerResumed()                     // User tapped "Resume"
TimerStopped()                     // User tapped "Stop"
TimerTicked(remainingSeconds)      // Internal: Timer emitted a tick
TimerFinished()                    // Internal: Timer reached 0
TimerErrorOccurred(message)        // Internal: Error in stream
```

**Key States:**

```dart
TimerInitial()                  // No timer set yet
TimerInputState()               // Waiting for user input
TimerRunning(timerValue)        // Counting down (show countdown + pause button)
TimerPaused(timerValue)         // Paused (show remaining time + resume button)
TimerFinished(timerValue)       // Finished (show "Time's up!" + start new button)
TimerError(message)             // Error occurred (show error + retry button)
```

**What the BLoC Does:**

```
1. Listen to user events (TimerStarted, TimerPaused, etc.)
2. For each event, call the appropriate usecase
3. Stream management: When timer starts, subscribe to timer ticks
4. Convert stream ticks into events (TimerTicked, TimerFinished)
5. Emit state changes to the UI
6. Manage state transitions (Running → Paused → Running → Finished)
7. Cleanup: Cancel stream when paused, resumed, or stopped
```

**Complex Part: Stream Subscription in BLoC**

```dart
// When timer starts, subscribe to the stream
_timerSubscription = _timerRepository.getTimerTicks().listen(
  (timerValue) {
    // Every second, the stream emits a new TimerValue
    // Convert it to an event
    if (timerValue.remainingSeconds <= 0) {
      add(const events.TimerFinished());  // Timer done
    } else {
      add(events.TimerTicked(timerValue.remainingSeconds));  // Still running
    }
  },
  onError: (error) {
    // If stream has an error, emit error event
    add(events.TimerErrorOccurred(error.toString()));
  },
);

// When paused, stop listening to ticks
await _timerSubscription?.cancel();

// When resumed, re-subscribe to ticks
_timerSubscription = _timerRepository.getTimerTicks().listen(...);

// When BLoC closes, cleanup
@override
Future<void> close() {
  _timerSubscription?.cancel();
  return super.close();
}
```

---

### Layer 4: Presentation - UI

**Files:**
- `pages/timer_page.dart` - The screen the user sees

**Key Screens Based on State:**

1. **Input Screen** (TimerInputState)
   - Text field for duration
   - "Start Timer" button

2. **Running Screen** (TimerRunning)
   - Large countdown display (MM:SS)
   - Progress bar
   - "Pause" and "Stop" buttons

3. **Paused Screen** (TimerPaused)
   - Remaining time display
   - "Resume" and "Stop" buttons

4. **Finished Screen** (TimerFinished)
   - "Time's Up!" message
   - "Start New Timer" button

5. **Error Screen** (TimerError)
   - Error message
   - "Try Again" button

---

## Data Flow: Complete Example

### User starts a 60-second timer

```
Step 1: User enters "60" and taps "Start Timer"
   ↓
Step 2: UI calls context.read<TimerBloc>().add(TimerStarted(60))
   ↓
Step 3: BLoC receives TimerStarted event
   ↓
Step 4: BLoC calls _onTimerStarted handler
   ↓
Step 5: Handler calls _startTimer(60) usecase
   ↓
Step 6: Usecase calls repository.startTimer(60)
   ↓
Step 7: Repository calls datasource.startTimer(60)
   ↓
Step 8: Datasource creates Timer.periodic(Duration(seconds: 1), ...)
   ↓
Step 9: Datasource initializes:
   _remainingSeconds = 60
   _totalSeconds = 60
   _isRunning = true
   ↓
Step 10: Datasource returns TimerValue(remaining: 60, total: 60, running: true)
   ↓
Step 11: Repository passes it back to BLoC
   ↓
Step 12: BLoC emits TimerRunning(timerValue)
   ↓
Step 13: BLoC subscribes to the stream: _timerRepository.getTimerTicks()
   ↓
Step 14: UI shows running screen with "60" seconds
   ↓
---WAITING 1 SECOND---
   ↓
Step 15: Timer fires (1 second passed)
   ↓
Step 16: Datasource decrements: _remainingSeconds = 59
   ↓
Step 17: Datasource creates TimerValue(remaining: 59, total: 60, running: true)
   ↓
Step 18: Datasource emits via stream: _timerController.add(timerValue)
   ↓
Step 19: BLoC's stream listener receives it
   ↓
Step 20: Listener checks: remainingSeconds > 0, so not finished yet
   ↓
Step 21: Listener adds event: TimerTicked(59)
   ↓
Step 22: BLoC's _onTimerTicked handler is called
   ↓
Step 23: Handler gets current state (TimerRunning)
   ↓
Step 24: Handler creates new TimerValue with remaining: 59
   ↓
Step 25: BLoC emits TimerRunning(newTimerValue)
   ↓
Step 26: UI rebuilds and shows "59" seconds
   ↓
---WAIT 59 MORE SECONDS---
   ↓
(Steps 15-26 repeat 59 times...)
   ↓
Step 27: Timer fires (60 seconds total have passed)
   ↓
Step 28: Datasource decrements: _remainingSeconds = 0
   ↓
Step 29: Datasource checks: remainingSeconds <= 0? YES!
   ↓
Step 30: Datasource sets _isRunning = false
   ↓
Step 31: Datasource cancels the Timer: _timer.cancel()
   ↓
Step 32: Datasource emits final TimerValue(remaining: 0, total: 60, running: false)
   ↓
Step 33: BLoC's stream listener receives it
   ↓
Step 34: Listener checks: remainingSeconds <= 0, so timer finished
   ↓
Step 35: Listener adds event: TimerFinished()
   ↓
Step 36: BLoC's _onTimerFinished handler is called
   ↓
Step 37: Handler cancels the stream subscription
   ↓
Step 38: Handler gets current state and emits TimerFinished state
   ↓
Step 39: UI shows finished screen with "00:00" and "Time's Up!" message
```

**That's 39 steps from start to finish!**

Notice:
- Most steps are automatic (stream handling, subscription management)
- Each step is testable
- The pattern scales to complex features
- State transitions are clear

---

## Key Concepts Explained

### 1. **Streams vs Futures**

**Future (Counter):**
```dart
Future<int> increment()  // Returns ONE value when done

int result = await increment();  // Wait for one result
```

**Stream (Timer):**
```dart
Stream<TimerValue> getTimerTicks()  // Returns MANY values over time

getTimerTicks().listen((timerValue) {
  // This callback is called multiple times
  // Once per second for the duration of the timer
});
```

**Analogy:**
- Future: Phone call (you call, wait for answer, get response)
- Stream: Radio broadcast (station broadcasts continuously, you tune in and listen)

---

### 2. **StreamController**

A tool to create and manage a stream:

```dart
// Create a broadcast stream (multiple listeners allowed)
final StreamController<TimerValue> _timerController =
  StreamController<TimerValue>.broadcast();

// Get the stream that others can listen to
Stream<TimerValue> get timerStream => _timerController.stream;

// Emit a new value
_timerController.add(timerValue);

// Cleanup when done
_timerController.close();
```

**Why broadcast?**
- Multiple listeners can subscribe to the same stream
- Timer ticks need to be heard by BLoC, UI, analytics, notifications, etc.
- Regular stream is single-listener only

---

### 3. **Timer.periodic()**

Dart's built-in timer mechanism:

```dart
Timer? _timer;

_timer = Timer.periodic(
  const Duration(seconds: 1),  // Callback every 1 second
  (timer) {
    // This is called every second
    _remainingSeconds--;
    _timerController.add(TimerValue(...));

    if (_remainingSeconds <= 0) {
      timer.cancel();  // Stop the timer
    }
  },
);
```

**Key points:**
- `Timer.periodic()` calls the callback repeatedly
- `Timer.oneShot()` calls once after delay
- Must be cancelled with `timer.cancel()` to cleanup
- If not cancelled, it keeps running until the app closes

---

### 4. **StreamSubscription**

Represents a listener to a stream:

```dart
// Subscribe to a stream
StreamSubscription? _subscription = myStream.listen(
  (value) {
    // Called when stream emits a value
  },
  onError: (error) {
    // Called if stream has an error
  },
  onDone: () {
    // Called when stream closes
  },
);

// Pause listening (doesn't stop the stream)
_subscription?.pause();

// Resume listening
_subscription?.resume();

// Stop listening (cleanup)
_subscription?.cancel();
```

**Why important for Timer:**
- When timer pauses, we cancel the subscription (so we don't receive ticks)
- When timer resumes, we create a new subscription
- When BLoC closes, we must cancel to avoid memory leaks

---

### 5. **State Transitions**

Timer can be in multiple states, and transitions are explicit:

```
TimerInputState
    ↓
    └─→ [user taps "Start"] → TimerRunning
             ↓
             ├─→ [user taps "Pause"] → TimerPaused
             │        ↓
             │        └─→ [user taps "Resume"] → TimerRunning (repeats)
             │
             ├─→ [user taps "Stop"] → TimerInputState
             │
             └─→ [timer reaches 0] → TimerFinished
                      ↓
                      └─→ [user taps "Start New"] → TimerInputState
```

**Key insight:**
- From TimerRunning, you can pause or stop
- From TimerPaused, you can resume or stop
- Only from Running can the timer finish naturally
- Error state can be reached from any state

---

## Comparing to Counter Pattern

### Counter (Simple Pattern)
```dart
// 1 event type per operation
class CounterIncremented extends CounterEvent {}

// 1 state type for updates
class CounterUpdated extends CounterState {
  final int value;
}

// Simple handler
Future<void> _onCounterIncremented(...) async {
  emit(CounterLoading());
  final counter = await _incrementCounter();
  emit(CounterUpdated(counter.value));
}
```

**Characteristics:**
- Discrete operations (one action = one result)
- No state transitions
- No long-running operations
- No stream subscription management

### Timer (Advanced Pattern)
```dart
// Multiple events per operation
class TimerStarted extends TimerEvent {}
class TimerTicked extends TimerEvent {}  // Internal event from stream
class TimerFinished extends TimerEvent {}
class TimerPaused extends TimerEvent {}

// Multiple state types for different UI states
class TimerRunning extends TimerState {}
class TimerPaused extends TimerState {}
class TimerFinished extends TimerState {}

// Complex handler with stream subscription
Future<void> _onTimerStarted(...) async {
  // Start the timer
  await _startTimer();

  // Subscribe to stream for continuous updates
  _timerSubscription = _timerRepository.getTimerTicks().listen(
    (timerValue) {
      add(events.TimerTicked(timerValue.remainingSeconds));
    },
  );

  emit(TimerRunning(...));
}
```

**Characteristics:**
- Continuous operations (one action = many results)
- Complex state transitions
- Long-running operations
- Stream subscription management critical

---

## Key Implementation Details

### Handling Pause/Resume

```dart
// When pausing, stop listening to ticks
Future<void> _onTimerPaused(...) async {
  await _timerSubscription?.cancel();  // Stop receiving updates
  final paused = await _pauseTimer();   // Tell datasource to pause
  emit(TimerPaused(paused));
}

// When resuming, restart the timer and re-subscribe
Future<void> _onTimerResumed(...) async {
  final resumed = await _resumeTimer();
  emit(TimerRunning(resumed));

  // Re-subscribe to stream
  _timerSubscription = _timerRepository.getTimerTicks().listen(...);
}
```

**Important:**
- Pause keeps the remaining time (datasource holds state)
- Resume continues from where it paused
- Both require re-synchronizing the stream subscription

### Cleanup and Resource Management

```dart
// In datasource
void dispose() {
  _cancelTimer();
  _timerController.close();  // Important: close the stream
}

// In BLoC
@override
Future<void> close() {
  _timerSubscription?.cancel();  // Important: cancel subscription
  return super.close();
}

// In UI page
@override
void dispose() {
  _durationController.dispose();  // Important: cleanup controllers
  super.dispose();
}
```

**Why critical:**
- Not closing streams = memory leaks
- Not cancelling timers = resource waste
- Not disposing controllers = disposed widget errors

---

## Learning Checklist

- [ ] Understand the difference between Future and Stream
- [ ] Understand what StreamController does
- [ ] Understand Timer.periodic() and why it must be cancelled
- [ ] Understand StreamSubscription and its lifecycle
- [ ] Understand state transitions (running → paused → finished)
- [ ] Understand why we need multiple events (TimerTicked, TimerFinished)
- [ ] Understand why stream subscription is managed in pause/resume
- [ ] Understand cleanup: cancelling timers, closing streams, disposing subscriptions
- [ ] Trace a complete timer flow: start → tick → tick → finish
- [ ] Trace pause/resume: running → paused → running
- [ ] Explain resource management requirements
- [ ] Identify where memory leaks could happen
- [ ] Modify timer to display MM:SS format (already done, but understand why)
- [ ] Modify timer to show progress bar (already done, but understand how)

---

## Try It Yourself

1. **Run the app** → Navigate to Timer feature
2. **Start a timer** → See countdown begin
3. **Pause it** → Verify it stops but keeps remaining time
4. **Resume it** → Verify it continues from pause
5. **Stop it** → Verify it resets
6. **Let it finish** → See completion screen
7. **Read the comments** → Understand each part
8. **Trace the flow** → Use print statements to see:
   - When events are added
   - When handlers are called
   - When states are emitted
   - When stream ticks arrive

### Code Tracing Exercise

Add print statements to see the flow:

```dart
// In timer_bloc.dart
Future<void> _onTimerStarted(...) async {
  print('EVENT: TimerStarted(${event.durationInSeconds})');
  final timerValue = await _startTimer(event.durationInSeconds);
  print('STATE: TimerRunning(remaining: ${timerValue.remainingSeconds})');
  emit(states.TimerRunning(timerValue));

  _timerSubscription = _timerRepository.getTimerTicks().listen(
    (timerValue) {
      print('STREAM: Got tick - remaining: ${timerValue.remainingSeconds}');
      add(events.TimerTicked(timerValue.remainingSeconds));
    },
  );
}
```

---

## Real-World Extensions

In a real app, you might:

1. **Notification**: Play sound when timer finishes
   - Add notification trigger in `_onTimerFinished`
   - Use flutter_local_notifications package

2. **Vibration**: Vibrate when timer finishes
   - Use vibration package
   - Add in finished state handler

3. **Background Timer**: Keep counting when app is in background
   - Use background_service package
   - More complex: separate isolate for timer

4. **Multiple Timers**: Track multiple timers simultaneously
   - Change datasource to manage list of timers
   - Add timer ID to events and states

5. **Persistent Timer**: Resume timer after app restart
   - Save timer state to SharedPreferences
   - Restore on app launch

6. **Preset Durations**: Quick buttons (1 min, 5 min, 10 min)
   - Add preset buttons to UI
   - Quick-start without input field

7. **Timer History**: Track previous timers
   - Save completed timers to local database
   - Display list of past timers

8. **Custom Colors**: Change color based on time remaining
   - Low time (< 10s): Red
   - Medium time: Yellow
   - High time: Green

---

## Understanding Async/Await in Timer

Timer code uses async/await heavily:

```dart
// Usecase
Future<TimerValue> call(int durationInSeconds) {
  return repository.startTimer(durationInSeconds);
}

// Repository delegates to datasource
Future<TimerValue> startTimer(int durationInSeconds) {
  return _datasource.startTimer(durationInSeconds);
}

// Datasource implementation
Future<TimerValue> startTimer(int durationInSeconds) async {
  // Do async setup
  _totalSeconds = durationInSeconds;
  _remainingSeconds = durationInSeconds;

  // Create timer (this is synchronous)
  _timer = Timer.periodic(...);

  // Return immediately (not waiting for timer to finish!)
  return TimerValue(...);
}
```

**Important distinction:**
- `startTimer()` returns immediately
- It doesn't wait for the timer to finish
- It just initializes and returns the starting state
- The actual countdown happens asynchronously via the stream

If we made `startTimer()` wait for the timer to finish, the app would freeze!

---

## Common Mistakes to Avoid

### 1. **Forgetting to Cancel Subscription**
```dart
// ❌ Memory leak!
_timerSubscription = _timerRepository.getTimerTicks().listen(...);
// Never cancel → consumes memory

// ✅ Correct
_timerSubscription = _timerRepository.getTimerTicks().listen(...);
// In pause handler:
await _timerSubscription?.cancel();
```

### 2. **Forgetting to Close StreamController**
```dart
// ❌ Memory leak!
_timerController.add(value);
// App closes without closing stream

// ✅ Correct
_timerController.add(value);
// In dispose:
_timerController.close();
```

### 3. **Forgetting to Cancel Timer**
```dart
// ❌ Resource leak!
_timer = Timer.periodic(...);
// Timer keeps running even after pause

// ✅ Correct
_timer = Timer.periodic(...);
// In pause:
_timer?.cancel();
```

### 4. **Not Handling State Transitions**
```dart
// ❌ Wrong state
if (state is TimerRunning) {
  emit(TimerPaused(...));  // But subscription still active!
}

// ✅ Correct
if (state is TimerRunning) {
  await _timerSubscription?.cancel();  // Cancel first
  emit(TimerPaused(...));
}
```

### 5. **Not Validating Input**
```dart
// ❌ No validation
Future<void> _onTimerStarted(TimerStarted event, ...) async {
  await _startTimer(event.durationInSeconds);  // Could be negative!
}

// ✅ Validate
if (event.durationInSeconds <= 0) {
  emit(TimerError('Duration must be positive'));
  return;
}
```

---

## Key Takeaway

**Timer demonstrates that BLoC isn't just for simple state changes. It scales to manage complex, long-running operations with streams, state transitions, and resource management.**

The pattern remains the same:
1. Domain layer: Define what can be done
2. Data layer: Implement how it's done
3. BLoC: Orchestrate domain and presentation
4. UI: React to state changes

But the BLoC becomes more sophisticated to handle:
- Multiple events (including system-generated ones)
- Stream subscriptions
- State transitions
- Resource cleanup

This is production-grade state management for real apps.

---

## Next Learning Steps

1. **Run the timer** and interact with it
2. **Read the source code** thoroughly with comments
3. **Trace the data flow** using print statements
4. **Modify it**: Add a progress bar, different states, etc.
5. **Compare with Counter** to understand complexity scaling
6. **Study Stream documentation** in Dart async docs
7. **Add error handling** for edge cases
8. **Extract common patterns** for reuse across features

---

Happy learning! 🎓
