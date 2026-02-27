/// CounterLocalDataSource: In-memory counter storage
///
/// This datasource stores the counter value in memory
/// In a real app, you would:
/// - Save to SQLite/Hive local database
/// - Save to SharedPreferences (for simple values)
/// - Save to cloud firestore
/// - Make API calls to a backend
///
/// Key Point: This class manages WHERE and HOW the data is stored
/// The repository doesn't care, it just calls methods here
class CounterLocalDataSource {
  /// Private variable to store the counter value
  /// This persists only for the lifetime of the app
  /// Close the app and it resets to 0
  int _counterValue = 0;

  /// Get the current counter value
  ///
  /// In this simple implementation, it's synchronous
  /// We wrap it in a Future to show that in a real app it could be async
  /// (network call, database query, etc.)
  Future<int> getCounter() async {
    return _counterValue;
  }

  /// Increment the counter
  ///
  /// Business logic: Add 1 to the current value
  /// Returns the new value
  Future<int> increment() async {
    _counterValue++;
    return _counterValue;
  }

  /// Decrement the counter
  ///
  /// Business logic: Subtract 1 from the current value
  /// Returns the new value
  Future<int> decrement() async {
    _counterValue--;
    return _counterValue;
  }

  /// Reset the counter to zero
  ///
  /// Business logic: Set value to 0
  /// Returns 0
  Future<int> reset() async {
    _counterValue = 0;
    return _counterValue;
  }
}
