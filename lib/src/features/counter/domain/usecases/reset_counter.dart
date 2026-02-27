import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

/// ResetCounter UseCase
///
/// Encapsulates the business logic of "reset the counter to zero"
class ResetCounter {
  final CounterRepository repository;

  ResetCounter(this.repository);

  Future<Counter> call() {
    return repository.reset();
  }
}
