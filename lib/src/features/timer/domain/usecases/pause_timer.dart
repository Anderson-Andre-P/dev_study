import '../entities/timer_value.dart';
import '../repositories/timer_repository.dart';

/// PauseTimer UseCase
///
/// Pause the currently running timer
/// The remaining time is preserved
class PauseTimer {
  final TimerRepository repository;

  PauseTimer(this.repository);

  Future<TimerValue> call() {
    return repository.pauseTimer();
  }
}
