import '../entities/timer_value.dart';
import '../repositories/timer_repository.dart';

/// ResumeTimer UseCase
///
/// Resume a paused timer
/// Continues counting down from where it was paused
class ResumeTimer {
  final TimerRepository repository;

  ResumeTimer(this.repository);

  Future<TimerValue> call() {
    return repository.resumeTimer();
  }
}
