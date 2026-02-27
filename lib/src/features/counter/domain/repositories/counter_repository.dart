import '../entities/counter.dart';

/// CounterRepository: Interface for counter data access
///
/// This defines what operations are available for counter.
/// The domain layer says "I need these operations"
/// The data layer says "Here's how to do them"
///
/// Current operations:
/// - Get current counter value
/// - Increment counter
/// - Decrement counter
/// - Reset counter to zero
abstract class CounterRepository {
  /// Get the current counter value
  /// In this simple example, it just returns the value
  /// In a real app, it might fetch from a database
  Future<Counter> getCounter();

  /// Increment the counter by 1
  /// Returns the new value
  Future<Counter> increment();

  /// Decrement the counter by 1
  /// Returns the new value
  Future<Counter> decrement();

  /// Reset the counter to 0
  /// Returns a counter with value 0
  Future<Counter> reset();
}
