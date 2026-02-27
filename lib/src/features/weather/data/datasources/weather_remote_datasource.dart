import 'dart:convert';
import 'package:http/http.dart' as http;

/// WeatherRemoteDataSource: Where the ACTUAL API CALL happens
///
/// This class is responsible for:
/// - Making HTTP requests to the weather API
/// - Parsing the JSON response
/// - Returning raw data (Maps) that the repository converts to entities
///
/// Using the `http` package:
/// - `http.get()`: Makes a GET request to a URL
/// - Returns an http.Response with status code and body
/// - Body is raw JSON string - we must parse it ourselves
///
/// Why separate from the repository?
/// - DataSource: Talks to external systems (APIs, databases)
/// - Repository: Orchestrates multiple datasources and converts to entities
/// - This separation makes it easy to swap datasources
///   (e.g., use cache if online fails, use API if cache is old)
class WeatherRemoteDataSource {
  /// Base URL for Open-Meteo free weather API
  /// This API doesn't require authentication (no API key needed!)
  /// Documentation: https://open-meteo.com/
  static const String _baseUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// Dependency: The HTTP client
  /// We accept it as a parameter to make testing easier
  /// (In tests, you can pass a mock http client)
  final http.Client _httpClient;

  WeatherRemoteDataSource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// getWeatherByCity: Fetch weather data from the API
  ///
  /// API Flow:
  /// 1. Use geocoding API to find coordinates of the city
  /// 2. Use weather API to get weather for those coordinates
  ///
  /// This method returns raw JSON as a Map (unstructured data)
  /// The repository layer will convert this to a Weather entity
  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      /// STEP 1: Get city coordinates using geocoding API
      ///
      /// This is a GET request to find the city's latitude/longitude
      /// We'll use this to get the actual weather
      final geoUrl = '$_baseUrl/search?name=$cityName&count=1&language=en&format=json';

      /// Make the GET request
      /// This is the KEY LINE where http package is used!
      /// http.get() returns a Future<http.Response>
      final geoResponse = await _httpClient.get(Uri.parse(geoUrl));

      /// Check if the request was successful (HTTP 200)
      if (geoResponse.statusCode != 200) {
        throw Exception('City not found: $cityName');
      }

      /// Parse the JSON response into a Map
      /// jsonDecode() converts JSON string to Dart Map
      /// {'results': [{'latitude': 37.7749, 'longitude': -122.4194, ...}]}
      final geoData = jsonDecode(geoResponse.body) as Map<String, dynamic>;

      /// Extract the results array
      final results = geoData['results'] as List?;
      if (results == null || results.isEmpty) {
        throw Exception('City not found: $cityName');
      }

      /// Get the first result (most relevant city)
      final cityData = results.first as Map<String, dynamic>;
      final latitude = cityData['latitude'] as num;
      final longitude = cityData['longitude'] as num;

      /// STEP 2: Get weather for the city coordinates
      ///
      /// Now that we have latitude/longitude, get the actual weather
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
          '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
          '&temperature_unit=celsius';

      /// Another GET request to fetch weather
      final weatherResponse = await _httpClient.get(Uri.parse(weatherUrl));

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to fetch weather');
      }

      /// Parse the weather API response
      /// The API returns: {'current': {'temperature_2m': 22.5, ...}}
      final weatherData = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
      final currentData = weatherData['current'] as Map<String, dynamic>;

      /// STEP 3: Transform raw API data into a structured Map
      ///
      /// The API gives us raw values. We transform them into a
      /// standardized format that our domain layer expects.
      ///
      /// Why transform here in the datasource?
      /// - Keep the transformation close to the API
      /// - Repository and domain stay independent of API structure
      /// - If the API changes, only datasource changes
      return {
        'city': cityData['name'] ?? 'Unknown',
        'temperature': (currentData['temperature_2m'] as num).toDouble(),
        'description': _weatherCodeToDescription(currentData['weather_code'] as int),
        'humidity': (currentData['relative_humidity_2m'] as num).toDouble(),
        'windSpeed': (currentData['wind_speed_10m'] as num).toDouble(),
      };
    } catch (e) {
      /// Any error (network, parsing, API error) is thrown
      /// The BLoC will catch this and emit an error state
      rethrow;
    }
  }

  /// _weatherCodeToDescription: Convert WMO weather codes to human-readable text
  ///
  /// The Open-Meteo API returns numeric weather codes.
  /// This helper converts them to readable descriptions.
  /// Reference: https://www.weatherapi.com/docs/weather_codes.json
  String _weatherCodeToDescription(int code) {
    return switch (code) {
      0 => 'Sunny',
      1 || 2 => 'Partly Cloudy',
      3 => 'Cloudy',
      45 || 48 => 'Foggy',
      51 || 53 || 55 => 'Light Rain',
      61 || 63 || 65 => 'Rain',
      80 || 81 || 82 => 'Heavy Rain',
      85 || 86 => 'Snow Showers',
      _ => 'Unknown',
    };
  }
}
