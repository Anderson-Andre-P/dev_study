import '../../domain/entities/timer_value.dart';
import '../../domain/repositories/timer_repository.dart';
import '../datasources/timer_datasource.dart';

/// TimerRepositoryImpl: Implementation of TimerRepository
///
/// Implements the timer operations defined in the domain layer
///
/// Key responsibility: Delegation
/// - Datasource handles HOW (implementation details)
/// - Repository handles WHAT (interface contract)
/// - Domain layer stays independent
class TimerRepositoryImpl implements TimerRepository {
  final TimerDataSource _datasource;

  TimerRepositoryImpl(this._datasource);

  @override
  Future<TimerValue> startTimer(int durationInSeconds) {
    return _datasource.startTimer(durationInSeconds);
  }

  @override
  Future<TimerValue> pauseTimer() {
    return _datasource.pauseTimer();
  }

  @override
  Future<TimerValue> resumeTimer() {
    return _datasource.resumeTimer();
  }

  @override
  Future<TimerValue> stopTimer() {
    return _datasource.stopTimer();
  }

  @override
  Stream<TimerValue> getTimerTicks() {
    return _datasource.timerStream;
  }

  @override
  Future<void> resetTimer() {
    return _datasource.resetTimer();
  }
}
