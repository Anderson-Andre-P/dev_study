import '../../domain/entities/weather.dart';

/// Weather States: The current state of the weather feature
///
/// States are the OUTPUT from the BLoC
/// The UI listens to these and updates what the user sees
abstract class WeatherState {
  const WeatherState();
}

/// WeatherInitial: The starting state
///
/// When the BLoC is first created, nothing has happened yet.
/// Show the empty search screen.
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// WeatherLoading: API call is in progress
///
/// When the user searches for a city, we emit this state.
/// The UI should show:
/// - A loading spinner
/// - A message like "Fetching weather..."
/// - Disable the search button
///
/// This state lasts until the API responds or errors.
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// WeatherLoaded: Successfully fetched weather data
///
/// The API returned data and we transformed it to a Weather entity.
/// The UI should display:
/// - City name
/// - Current temperature
/// - Weather description
/// - Humidity and wind speed
/// - Maybe an icon representing the weather
class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded(this.weather);
}

/// WeatherError: Something went wrong
///
/// The API call failed or there was another error.
/// The UI should show:
/// - An error icon
/// - The error message
/// - A "Retry" button to try again
/// - The search box for trying a different city
///
/// Common errors:
/// - Network error (no internet)
/// - City not found
/// - API error (service down)
class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);
}
