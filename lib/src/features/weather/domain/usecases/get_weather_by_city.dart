import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// GetWeatherByCity: A USE CASE in the DOMAIN LAYER
///
/// What is a UseCase?
/// A usecase is a specific business action. It encapsulates a business rule.
///
/// "GetWeatherByCity" = The business action of "retrieve weather for a city"
///
/// Why separate from the repository?
/// - Repository handles data access
/// - UseCase handles business logic
/// - If you need multiple repositories or transformation, usecase handles it
///
/// Example: If you need to validate the city name before calling the repository,
/// that logic goes here in the usecase, not in the repository.
class GetWeatherByCity {
  final WeatherRepository repository;

  /// Constructor: Receives the repository via dependency injection
  /// This makes it testable - you can pass a fake repository in tests
  GetWeatherByCity(this.repository);

  /// call(): The main method of the usecase
  /// Using "call()" as the method name is a convention - it allows you to:
  ///   usecase() instead of usecase.execute()
  /// But we'll use a named method for clarity
  ///
  /// Flow:
  /// 1. Receive city name
  /// 2. Call repository to fetch weather
  /// 3. Return the weather data
  /// 4. If error occurs, let it bubble up (BLoC will catch it)
  Future<Weather> call(String cityName) {
    // In a real usecase, you might:
    // - Validate the city name
    // - Cache the result
    // - Transform the data
    // - Check multiple data sources
    //
    // For simplicity, we just delegate to the repository
    return repository.getWeatherByCity(cityName);
  }
}
