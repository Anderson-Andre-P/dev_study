import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// IncrementCounter UseCase
///
/// This usecase encapsulates the business logic of "increment the counter"
/// Even though this is simple (just calls repository), the pattern is important.
///
/// Why have a usecase for such simple logic?
/// - Consistency: All features have usecases
/// - Flexibility: If business logic grows, it's in the right place
/// - Testability: Easy to test usecases independently
/// - Reusability: UI doesn't know how to increment, it just calls this
class IncrementCounter {
  final CounterRepository repository;

  IncrementCounter(this.repository);

  /// call: Execute the increment operation
  /// Returns a Future because in a real app, this might be async
  /// (e.g., save to database, network request)
  Future<Counter> call() {
    return repository.increment();
  }
}
