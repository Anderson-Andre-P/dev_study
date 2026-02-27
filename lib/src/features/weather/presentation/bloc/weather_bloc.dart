import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_weather_by_city.dart';
import 'weather_event.dart';
import 'weather_state.dart';

/// WeatherBloc: The state management for weather feature
///
/// Remember the architecture:
///   UI (WeatherPage)
///     ↓ sends events to
///   BLoC (WeatherBloc) ← YOU ARE HERE
///     ↓ uses
///   Domain (GetWeatherByCity usecase)
///     ↓ uses
///   Data Layer (WeatherRemoteDataSource → API)
///
/// The BLoC:
/// 1. Listens for FetchWeatherRequested events
/// 2. Calls the domain usecase to get weather
/// 3. The usecase internally:
///    - Calls the repository
///    - Repository calls the datasource
///    - Datasource makes HTTP request to API
///    - Datasource parses response
///    - Repository transforms to entity
///    - Usecase returns Weather
/// 4. BLoC emits states that UI listens to
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherByCity _getWeatherByCity;

  WeatherBloc(this._getWeatherByCity) : super(const WeatherInitial()) {
    /// Register the handler for FetchWeatherRequested events
    on<FetchWeatherRequested>(_onFetchWeatherRequested);
  }

  /// _onFetchWeatherRequested: Handle user searching for weather
  ///
  /// This is called when the user:
  /// - Types a city name and taps "Search"
  /// - Taps "Retry" after an error
  ///
  /// Flow:
  /// 1. Emit WeatherLoading (show spinner)
  /// 2. Call domain usecase
  /// 3. If success: Emit WeatherLoaded with data
  /// 4. If error: Emit WeatherError with message
  Future<void> _onFetchWeatherRequested(
    FetchWeatherRequested event,
    Emitter<WeatherState> emit,
  ) async {
    // Show loading state while fetching
    emit(const WeatherLoading());

    try {
      // Call the domain usecase
      // This triggers the entire chain:
      // usecase → repository → datasource → HTTP request → API
      final weather = await _getWeatherByCity(event.cityName);

      // Success! Emit the loaded state with the weather data
      emit(WeatherLoaded(weather));
    } catch (e) {
      // Error! Emit error state with the error message
      // The error could be from:
      // - Network error (no internet)
      // - City not found
      // - API error
      emit(WeatherError('Failed to fetch weather: ${e.toString()}'));
    }
  }
}
