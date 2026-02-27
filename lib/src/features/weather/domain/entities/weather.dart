/// Weather Entity: Represents weather information in the DOMAIN LAYER
///
/// This entity is:
/// - Independent of any framework (no Flutter, no HTTP imports)
/// - Independent of how data is fetched (API, database, etc.)
/// - The business model of what "weather data" is
///
/// It only describes the STRUCTURE of weather information, not where it comes from.
class Weather {
  final String city;
  final double temperature; // in Celsius
  final String description; // e.g., "Sunny", "Rainy"
  final double humidity; // percentage (0-100)
  final double windSpeed; // in km/h

  const Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });
}
