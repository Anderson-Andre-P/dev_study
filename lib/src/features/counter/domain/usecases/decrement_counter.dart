import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// DecrementCounter UseCase
///
/// Symmetrical to IncrementCounter
/// Encapsulates the business logic of "decrement the counter"
class DecrementCounter {
  final CounterRepository repository;

  DecrementCounter(this.repository);

  Future<Counter> call() {
    return repository.decrement();
  }
}
