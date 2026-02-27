/// Weather Events: What the user can do with weather
///
/// Events are the INPUT to the BLoC
/// When the user does something, we create an event and add it to the BLoC
abstract class WeatherEvent {
  const WeatherEvent();
}

/// FetchWeatherRequested: User wants to see weather for a city
///
/// Triggered when:
/// - User types a city name and taps "Search"
/// - User opens the weather page for the first time
/// - User taps the "Retry" button after an error
class FetchWeatherRequested extends WeatherEvent {
  final String cityName;

  /// Constructor: The event carries the city name the user is asking for
  const FetchWeatherRequested(this.cityName);
}
