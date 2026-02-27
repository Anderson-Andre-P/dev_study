import '../entities/weather.dart';

/// WeatherRepository: The INTERFACE that defines data access rules
///
/// In clean architecture, the domain layer DEFINES what data access should look like
/// (via this interface), but doesn't implement it.
///
/// Why?
/// - Domain stays independent of implementation details
/// - You can swap implementations without changing domain logic
/// - Easy to mock for testing
///
/// The data layer implements this interface in WeatherRepositoryImpl
abstract class WeatherRepository {
  /// Get weather for a specific city
  ///
  /// Takes a city name (string) and returns a Future of Weather
  /// The Future allows for async operations (API calls take time)
  ///
  /// Can throw an exception if:
  /// - City not found
  /// - Network error
  /// - API error
  Future<Weather> getWeatherByCity(String cityName);
}
