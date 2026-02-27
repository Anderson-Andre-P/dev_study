import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/increment_counter.dart';
import '../../domain/usecases/reset_counter.dart';
import 'counter_event.dart';
import 'counter_state.dart';

/// CounterBloc: The HEART of the counter feature
///
/// This is where the magic happens!
/// The BLoC:
/// 1. Listens for events from the UI
/// 2. Calls domain layer usecases
/// 3. Emits new states
/// 4. The UI rebuilds based on the new state
///
/// Data Flow:
/// User taps "+" button
///   ↓
/// UI sends CounterIncremented event
///   ↓
/// BLoC receives event
///   ↓
/// BLoC calls _incrementCounter usecase
///   ↓
/// Usecase calls repository.increment()
///   ↓
/// Repository calls datasource.increment()
///   ↓
/// Datasource updates internal value
///   ↓
/// Value flows back up: datasource → repository → usecase → BLoC
///   ↓
/// BLoC emits CounterUpdated state with new value
///   ↓
/// UI listens to state change
///   ↓
/// UI rebuilds with new value on screen
///
/// That's a lot of steps for incrementing a number!
/// But notice: each step is simple and focused.
/// Easy to test, easy to maintain, easy to extend.
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  /// The three usecases for counter operations
  /// These are injected via the constructor (Dependency Injection)
  final IncrementCounter _incrementCounter;
  final DecrementCounter _decrementCounter;
  final ResetCounter _resetCounter;

  /// Constructor
  /// Takes three usecases and sets initial state to CounterInitial
  CounterBloc(
    this._incrementCounter,
    this._decrementCounter,
    this._resetCounter,
  ) : super(const CounterInitial()) {
    /// Register event handlers
    /// When CounterIncremented event is received, call _onCounterIncremented
    on<CounterIncremented>(_onCounterIncremented);
    on<CounterDecremented>(_onCounterDecremented);
    on<CounterReset>(_onCounterReset);
  }

  /// Handle CounterIncremented event
  /// This is called when the user presses the increment button
  Future<void> _onCounterIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) async {
    try {
      // Emit loading state (UI shows spinner, though it's very fast)
      emit(const CounterLoading());

      // Call the increment usecase
      // This goes through: usecase → repository → datasource → back
      final counter = await _incrementCounter();

      // Emit the new value
      // UI now shows the updated counter
      emit(CounterUpdated(counter.value));
    } catch (e) {
      // If something goes wrong, emit error state
      emit(CounterError('Failed to increment: ${e.toString()}'));
    }
  }

  /// Handle CounterDecremented event
  /// Same pattern as increment, but calls decrement usecase
  Future<void> _onCounterDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) async {
    try {
      emit(const CounterLoading());

      final counter = await _decrementCounter();

      emit(CounterUpdated(counter.value));
    } catch (e) {
      emit(CounterError('Failed to decrement: ${e.toString()}'));
    }
  }

  /// Handle CounterReset event
  /// Resets the counter back to zero
  Future<void> _onCounterReset(
    CounterReset event,
    Emitter<CounterState> emit,
  ) async {
    try {
      emit(const CounterLoading());

      final counter = await _resetCounter();

      emit(CounterUpdated(counter.value));
    } catch (e) {
      emit(CounterError('Failed to reset: ${e.toString()}'));
    }
  }
}
