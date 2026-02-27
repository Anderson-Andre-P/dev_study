import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';

/// CounterRepositoryImpl: Implementation of CounterRepository
///
/// The repository's job is to:
/// 1. Take raw data from the datasource (int)
/// 2. Transform it to domain entities (Counter)
/// 3. Implement the repository interface
///
/// This keeps the domain layer clean:
/// - Domain doesn't know about datasource
/// - Domain doesn't know about data types
/// - Domain just knows "I get Counter objects"
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource _datasource;

  CounterRepositoryImpl(this._datasource);

  /// Get the current counter
  /// Transforms: int (from datasource) → Counter (domain entity)
  @override
  Future<Counter> getCounter() async {
    final value = await _datasource.getCounter();
    return Counter(value: value);
  }

  /// Increment the counter
  /// Transforms: int → Counter
  @override
  Future<Counter> increment() async {
    final value = await _datasource.increment();
    return Counter(value: value);
  }

  /// Decrement the counter
  /// Transforms: int → Counter
  @override
  Future<Counter> decrement() async {
    final value = await _datasource.decrement();
    return Counter(value: value);
  }

  /// Reset the counter
  /// Transforms: int → Counter
  @override
  Future<Counter> reset() async {
    final value = await _datasource.reset();
    return Counter(value: value);
  }
}
