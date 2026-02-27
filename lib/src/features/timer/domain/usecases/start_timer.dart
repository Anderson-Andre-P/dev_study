import '../entities/timer_value.dart';
import '../repositories/timer_repository.dart';

/// StartTimer UseCase
///
/// Encapsulates the business logic: "Start a countdown timer"
///
/// Input: How many seconds to countdown
/// Output: Initial timer state
///
/// This usecase doesn't do much itself (just calls repository),
/// but in a real app it might:
/// - Validate the duration (can't be negative, can't be too long)
/// - Log analytics ("User started a timer")
/// - Check if another timer is already running
class StartTimer {
  final TimerRepository repository;

  StartTimer(this.repository);

  /// Start a timer with the given duration in seconds
  ///
  /// Why is this async?
  /// - In this simple example, it's not really async
  /// - But in a real app, starting a timer might involve:
  ///   - Saving to database
  ///   - Requesting permissions (if system timer)
  ///   - Making API call (server-side timer)
  Future<TimerValue> call(int durationInSeconds) {
    // Could add validation here:
    // if (durationInSeconds <= 0) throw Exception('Duration must be positive');
    // if (durationInSeconds > 3600) throw Exception('Max 1 hour');

    return repository.startTimer(durationInSeconds);
  }
}
