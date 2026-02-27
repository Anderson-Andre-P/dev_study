import '../entities/timer_value.dart';
import '../repositories/timer_repository.dart';

/// StopTimer UseCase
///
/// Stop the timer completely
/// The timer resets to 0 and stops running
/// User can then start a new timer
class StopTimer {
  final TimerRepository repository;

  StopTimer(this.repository);

  Future<TimerValue> call() {
    return repository.stopTimer();
  }
}
