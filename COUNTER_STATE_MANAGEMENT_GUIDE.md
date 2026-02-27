# Counter: BLoC State Management Learning Guide

## Overview

The **Counter** feature is a simple but complete example of the **BLoC state management pattern** in action. It demonstrates how to build a feature from scratch using clean architecture.

This guide explains every concept in detail.

---

## What is the Counter?

A simple app that:
- Displays a number (0, 1, 2, 3, ...)
- Has three buttons: `+`, `-`, `Reset`
- Updates the displayed number when you tap a button

**But here's the learning:** We're NOT just updating a variable and calling `setState()`. Instead, we're using a complete architectural pattern that's scalable, testable, and maintainable.

---

## The 4-Layer Architecture

### Layer 1: Domain (Business Logic)

**Files:**
- `entities/counter.dart` - What a counter is
- `repositories/counter_repository.dart` - What operations we can do
- `usecases/increment_counter.dart`, etc. - How to perform each operation

**Key Point:** This layer knows NOTHING about:
- Flutter
- Mobile apps
- Databases
- UIs

It's pure business logic. You could run this in a backend, CLI app, web server, anywhere.

**What it does:**
```
Counter entity (holds a value)
    ↑
CounterRepository interface (defines operations)
    ↑
UseCases (implement business logic)
    - IncrementCounter: add 1
    - DecrementCounter: subtract 1
    - ResetCounter: set to 0
```

### Layer 2: Data (How to Store/Fetch)

**Files:**
- `datasources/counter_local_datasource.dart` - Where the data lives
- `repositories/counter_repository_impl.dart` - Transforms raw data to entities

**Key Point:** This layer knows HOW and WHERE data is stored:
- In this example: in-memory (lost when app closes)
- In real apps: SQLite, Firestore, SharedPreferences, etc.

**What it does:**
```
Raw int value (5)
    ↓
DataSource: increment to 6
    ↓
Repository: transform 6 → Counter(value: 6)
    ↓
Return to domain layer
```

### Layer 3: Presentation - BLoC (State Management)

**Files:**
- `bloc/counter_event.dart` - What the user does
- `bloc/counter_state.dart` - What the UI shows
- `bloc/counter_bloc.dart` - The orchestrator

**Key Point:** The BLoC sits between the UI and domain:
- Receives events FROM the UI
- Calls domain layer usecases
- Emits states that the UI listens to

**What it does:**
```
User taps "+" button
    ↓
UI sends CounterIncremented event to BLoC
    ↓
BLoC receives event
    ↓
BLoC calls IncrementCounter usecase
    ↓
Usecase returns new Counter value
    ↓
BLoC emits CounterUpdated state
    ↓
UI listens to state
    ↓
UI rebuilds with new value
```

### Layer 4: Presentation - UI

**Files:**
- `pages/counter_page.dart` - The screen the user sees

**Key Point:** The UI is REACTIVE:
- Doesn't manage logic
- Doesn't manipulate state directly
- Just sends events and listens to state changes

**What it does:**
```
User taps button
    ↓
Send event: context.read<CounterBloc>().add(CounterIncremented())
    ↓
BLocBuilder listens for state changes
    ↓
State changes → UI rebuilds automatically
```

---

## Data Flow: Complete Example

### User taps the "+" button

```
Step 1: User taps "+" button
   ↓
Step 2: OnPressed callback fires
   ↓
Step 3: UI sends event to BLoC
   context.read<CounterBloc>().add(CounterIncremented());
   ↓
Step 4: BLoC receives CounterIncremented event
   ↓
Step 5: BLoC's _onCounterIncremented handler is called
   ↓
Step 6: BLoC emits CounterLoading state
   ↓
Step 7: BLoC calls _incrementCounter usecase
   ↓
Step 8: Usecase calls repository.increment()
   ↓
Step 9: Repository calls datasource.increment()
   ↓
Step 10: Datasource increments its internal value (5 → 6)
   ↓
Step 11: Datasource returns 6 to repository
   ↓
Step 12: Repository transforms 6 → Counter(value: 6)
   ↓
Step 13: Repository returns Counter to usecase
   ↓
Step 14: Usecase returns Counter to BLoC
   ↓
Step 15: BLoC emits CounterUpdated(6) state
   ↓
Step 16: BlocBuilder detects state change
   ↓
Step 17: BlocBuilder's builder function is called with new state
   ↓
Step 18: UI shows: Text('6')
```

**That's 18 steps to show a number!**

But notice:
- Each step is simple and focused
- Easy to test each step independently
- Easy to change any step without breaking others
- Easy to add features (save to database, sync to server, etc.)

---

## Key Concepts Explained

### 1. **Events = User Actions**

```dart
abstract class CounterEvent {
  const CounterEvent();
}

class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}
```

**What it means:**
- User did something (tapped a button)
- We create an event to represent it
- We send it to the BLoC

**Real-world analogy:**
- You go to a restaurant
- You write down your order (event)
- You give it to the waiter (BLoC)
- The kitchen (usecase) processes it

### 2. **States = UI Updates**

```dart
abstract class CounterState {
  const CounterState();
}

class CounterUpdated extends CounterState {
  final int value;
  const CounterUpdated(this.value);
}
```

**What it means:**
- The BLoC emits a state
- The state describes what the UI should show
- The UI automatically updates

**Real-world analogy:**
- The kitchen finishes your food
- They give the waiter the plate (state)
- The waiter delivers it to your table
- You see it and eat (UI shows it)

### 3. **BlocBuilder = Reactive UI**

```dart
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    if (state is CounterUpdated) {
      return Text('${state.value}');
    }
  }
)
```

**What it means:**
- The BlocBuilder listens to BLoC state changes
- Whenever the state changes, the builder is called
- The builder returns updated UI

**Real-world analogy:**
- You have a bell on your table
- When food arrives, the waiter rings the bell (state change)
- You hear it and eat (UI rebuilds)

### 4. **No setState() Needed**

**Old way (setState):**
```dart
// ❌ Bad
int counter = 0;

void increment() {
  counter++;
  setState(() {}); // Have to manually tell Flutter to rebuild
}
```

**BLoC way:**
```dart
// ✅ Good
// Just emit a state
emit(CounterUpdated(6));

// BlocBuilder automatically detects the change and rebuilds
// No setState() needed!
```

---

## Why This Pattern Matters

### 1. **Testability**

Test the BLoC without building a UI:
```dart
test('increment counter', () async {
  final bloc = CounterBloc(...);
  bloc.add(CounterIncremented());

  expect(
    bloc.stream,
    emits(CounterUpdated(1)),
  );
});
```

### 2. **Reusability**

The domain layer can be used anywhere:
```dart
// Backend API
final counter = await IncrementCounter(repository).call();

// CLI app
final counter = await IncrementCounter(repository).call();

// Mobile app
// Same code!
```

### 3. **Maintainability**

Change one layer without affecting others:
```dart
// Want to save to database instead of memory?
// Just change the datasource
// BLoC, domain, UI stay the same
```

### 4. **Scalability**

Easy to add features:
```dart
// Add "increment by 5" feature?
// Just add a new event and usecase
// No need to refactor existing code
```

---

## Comparing to Other Patterns

### setState() Pattern
```dart
// ❌ Simple but doesn't scale
class CounterPage extends StatefulWidget {
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int counter = 0;

  void increment() {
    setState(() => counter++);
  }
}
```

**Problems:**
- Hard to test (UI and logic mixed)
- Doesn't scale well
- Manual state management
- Tight coupling

### BLoC Pattern
```dart
// ✅ More code, but scalable
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  // Clear separation of concerns
  // Easy to test
  // Easy to scale
}
```

**Benefits:**
- Testable business logic
- Clear data flow
- Easy to maintain
- Scales to large apps

---

## How to Read the Code

### In counter_bloc.dart:
```dart
Future<void> _onCounterIncremented(
  CounterIncremented event,
  Emitter<CounterState> emit,
) async {
  try {
    emit(const CounterLoading());
    final counter = await _incrementCounter();
    emit(CounterUpdated(counter.value));
  } catch (e) {
    emit(CounterError('Failed'));
  }
}
```

**What it means:**
1. **Event received:** `_onCounterIncremented` is called
2. **Show loading:** `emit(const CounterLoading())`
3. **Get new value:** `await _incrementCounter()`
4. **Show result:** `emit(CounterUpdated(...))`
5. **Handle error:** `catch (e) { emit(CounterError(...)) }`

### In counter_page.dart:
```dart
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    if (state is CounterUpdated) {
      return Text('${state.value}');
    }
  }
)
```

**What it means:**
1. **Listen to state:** BlocBuilder listens for state changes
2. **Check state type:** `if (state is CounterUpdated)`
3. **Build UI:** Return the appropriate widget
4. **Auto-rebuild:** When state changes, builder is called again

---

## Learning Checklist

- [ ] Understand what an entity is
- [ ] Understand what a repository does
- [ ] Understand what a usecase is
- [ ] Understand the difference between event and state
- [ ] Understand how the BLoC connects layers
- [ ] Understand how BlocBuilder listens to state
- [ ] Trace the complete data flow (user → UI → BLoC → domain → data → back to UI)
- [ ] Understand why each layer exists
- [ ] Explain the pattern to someone else
- [ ] Modify the counter to have different buttons/features

---

## Try It Yourself

1. **Run the app** → Tap "Counter" in Study Hub
2. **Tap buttons** → Watch the counter update
3. **Read the comments** → Understand each part
4. **Trace the flow** → Follow a button press through all layers
5. **Modify it** → Add a "increment by 5" button
   - Add new event: `IncrementByFive`
   - Add new usecase: `IncrementCounterBy(int amount)`
   - Add new handler in BLoC
   - Add new button in UI

---

## Real-World Extensions

In a real app, you might:
- **Save to database:** Counter persists after app closes
- **Sync to server:** Counter syncs across devices
- **Add validation:** Counter can't go below 0
- **Add analytics:** Track how many times user increments
- **Add undo/redo:** Keep history of counter values
- **Add themes:** Different UI based on counter value

All of these are easy to add because of the architecture!

---

## Key Takeaway

**BLoC is not just about managing state. It's about organizing code in a way that's testable, scalable, and maintainable.**

The counter is simple, but the pattern works for apps with thousands of features.

---

Happy learning! 🎓

