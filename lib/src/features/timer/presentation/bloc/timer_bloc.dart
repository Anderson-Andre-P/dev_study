import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/timer_value.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../domain/usecases/pause_timer.dart';
import '../../domain/usecases/resume_timer.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/stop_timer.dart';
import 'timer_event.dart' as events;
import 'timer_state.dart' as states;

/// TimerBloc: State management for the timer feature
///
/// This BLoC is more complex than Counter because:
/// - It manages a long-running operation (the timer)
/// - It listens to a stream of updates (timer ticks)
/// - It handles state transitions (running → paused → finished)
///
/// Key difference from Counter:
/// Counter: Simple discrete operations
/// Timer: Stream of continuous events + state transitions
///
/// What the BLoC does:
/// 1. Listen for user events (start, pause, resume, stop)
/// 2. Call usecases to execute operations
/// 3. Listen to the timer stream and convert ticks to events
/// 4. Emit state changes to the UI
/// 5. Handle cleanup and teardown
class TimerBloc extends Bloc<events.TimerEvent, states.TimerState> {
  final StartTimer _startTimer;
  final PauseTimer _pauseTimer;
  final ResumeTimer _resumeTimer;
  final StopTimer _stopTimer;
  final TimerRepository _timerRepository;

  /// Store subscription to timer stream
  /// We need to keep track of this so we can cancel it
  StreamSubscription? _timerSubscription;

  TimerBloc(
    this._startTimer,
    this._pauseTimer,
    this._resumeTimer,
    this._stopTimer,
    this._timerRepository,
  ) : super(const states.TimerInitial()) {
    /// Register all event handlers
    on<events.TimerStarted>(_onTimerStarted);
    on<events.TimerPaused>(_onTimerPaused);
    on<events.TimerResumed>(_onTimerResumed);
    on<events.TimerStopped>(_onTimerStopped);
    on<events.TimerTicked>(_onTimerTicked);
    on<events.TimerFinished>(_onTimerFinished);
    on<events.TimerErrorOccurred>(_onTimerErrorOccurred);
  }

  /// Handle TimerStarted event
  /// User entered duration and tapped "Start"
  Future<void> _onTimerStarted(
    events.TimerStarted event,
    Emitter<states.TimerState> emit,
  ) async {
    try {
      // Validate input
      if (event.durationInSeconds <= 0) {
        emit(const states.TimerError('Duration must be greater than 0'));
        return;
      }

      // Start the timer in the domain layer
      final timerValue = await _startTimer(event.durationInSeconds);

      // Emit running state
      emit(states.TimerRunning(timerValue));

      // Cancel any previous subscription
      await _timerSubscription?.cancel();

      // Listen to the timer stream
      // Every time the timer ticks (every second), we get a new TimerValue
      _timerSubscription = _timerRepository
          .getTimerTicks()
          .listen(
        (timerValue) {
          // Convert stream value to event
          if (timerValue.remainingSeconds <= 0) {
            // Timer finished
            add(const events.TimerFinished());
          } else {
            // Timer still running, emit tick event
            add(events.TimerTicked(timerValue.remainingSeconds));
          }
        },
        onError: (error) {
          // Error in timer stream - emit error state
          add(events.TimerErrorOccurred(error.toString()));
        },
      );
    } catch (e) {
      emit(states.TimerError('Failed to start timer: ${e.toString()}'));
    }
  }

  /// Handle TimerTicked event
  /// The timer emitted a tick (every second)
  Future<void> _onTimerTicked(
    events.TimerTicked event,
    Emitter<states.TimerState> emit,
  ) async {
    // Get current state to know what to emit
    final currentState = state;

    // Only emit if timer is running
    if (currentState is states.TimerRunning) {
      // The timerValue will be retrieved from the stream
      // For now, just update with remaining seconds
      emit(
        states.TimerRunning(
          currentState.timerValue.copyWith(
            remainingSeconds: event.remainingSeconds,
          ),
        ),
      );
    }
  }

  /// Handle TimerFinished event
  /// Timer reached 0
  Future<void> _onTimerFinished(
    events.TimerFinished event,
    Emitter<states.TimerState> emit,
  ) async {
    // Cancel the stream subscription
    await _timerSubscription?.cancel();

    // Get the final state
    final currentState = state;
    if (currentState is states.TimerRunning) {
      emit(states.TimerFinished(currentState.timerValue));
    }
  }

  /// Handle TimerPaused event
  /// User tapped pause button
  Future<void> _onTimerPaused(
    events.TimerPaused event,
    Emitter<states.TimerState> emit,
  ) async {
    try {
      // Cancel listening to ticks while paused
      await _timerSubscription?.cancel();

      // Pause in domain layer
      final timerValue = await _pauseTimer();

      // Emit paused state
      emit(states.TimerPaused(timerValue));
    } catch (e) {
      emit(states.TimerError('Failed to pause timer: ${e.toString()}'));
    }
  }

  /// Handle TimerResumed event
  /// User tapped resume button (when paused)
  Future<void> _onTimerResumed(
    events.TimerResumed event,
    Emitter<states.TimerState> emit,
  ) async {
    try {
      // Resume in domain layer
      final timerValue = await _resumeTimer();

      // Emit running state
      emit(states.TimerRunning(timerValue));

      // Re-subscribe to timer ticks
      _timerSubscription = _timerRepository.getTimerTicks().listen(
        (newTimerValue) {
          if (newTimerValue.remainingSeconds <= 0) {
            add(const events.TimerFinished());
          } else {
            add(events.TimerTicked(newTimerValue.remainingSeconds));
          }
        },
        onError: (error) {
          add(events.TimerErrorOccurred(error.toString()));
        },
      );
    } catch (e) {
      emit(states.TimerError('Failed to resume timer: ${e.toString()}'));
    }
  }

  /// Handle TimerStopped event
  /// User tapped stop button
  Future<void> _onTimerStopped(
    events.TimerStopped event,
    Emitter<states.TimerState> emit,
  ) async {
    try {
      // Cancel listening to ticks
      await _timerSubscription?.cancel();

      // Stop in domain layer
      await _stopTimer();

      // Go back to input state so user can start a new timer
      emit(const states.TimerInputState());
    } catch (e) {
      emit(states.TimerError('Failed to stop timer: ${e.toString()}'));
    }
  }

  /// Handle TimerErrorOccurred event
  /// An error happened in the timer stream
  Future<void> _onTimerErrorOccurred(
    events.TimerErrorOccurred event,
    Emitter<states.TimerState> emit,
  ) async {
    // Cancel any active subscription
    await _timerSubscription?.cancel();

    // Emit error state with the error message
    emit(states.TimerError('Timer error: ${event.message}'));
  }

  /// Cleanup when BLoC is closed
  /// Very important! Must cancel subscriptions
  /// Otherwise the app will leak resources
  @override
  Future<void> close() {
    // Cancel the timer subscription
    _timerSubscription?.cancel();
    return super.close();
  }
}

/// Helper extension to make TimerValue copyable
extension TimerValueCopy on TimerValue {
  TimerValue copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
  }) {
    return TimerValue(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
