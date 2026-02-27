import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

/// WeatherRepositoryImpl: Implements the WeatherRepository interface
///
/// In clean architecture, the repository is the ADAPTER that:
/// - Takes raw data from datasources
/// - Transforms it into domain entities
/// - Handles multiple datasources (cache, remote, local)
///
/// This separates:
/// - DataSource Layer: How to fetch data (HTTP, database, etc.)
/// - Domain Layer: What the data structure should be
/// - Repository: The translation between them
///
/// Pattern: Raw Map from DataSource → Domain Entity
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;

  /// Constructor: Receives the datasource via dependency injection
  WeatherRepositoryImpl(this._remoteDataSource);

  /// Implements the getWeatherByCity method from WeatherRepository interface
  @override
  Future<Weather> getWeatherByCity(String cityName) async {
    // STEP 1: Get raw data from the datasource (API)
    // This returns Map<String, dynamic> with raw API data
    final rawData = await _remoteDataSource.getWeatherByCity(cityName);

    // STEP 2: Transform raw Map → Domain Entity
    // This is the KEY transformation in clean architecture!
    //
    // rawData is unstructured: {'city': 'London', 'temperature': 22.5, ...}
    // Weather is structured: Weather(city: 'London', temperature: 22.5, ...)
    //
    // Why transform?
    // - Raw data is fragile (API structure can change)
    // - Domain entities are stable (your app logic depends on them)
    // - If API changes, only repository changes, not domain
    return Weather(
      city: rawData['city'] as String,
      temperature: rawData['temperature'] as double,
      description: rawData['description'] as String,
      humidity: rawData['humidity'] as double,
      windSpeed: rawData['windSpeed'] as double,
    );
  }
}
