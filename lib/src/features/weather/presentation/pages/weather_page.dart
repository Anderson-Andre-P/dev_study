import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/theme/app_spacing.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

/// WeatherPage: The UI for the weather feature
///
/// This is a PRESENTATION LAYER widget that:
/// - Displays the UI to the user
/// - Listens to BLoC state changes
/// - Sends events to the BLoC when user interacts
///
/// It NEVER directly calls the domain layer or makes API calls
/// All of that is delegated to the BLoC
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  /// Controller to manage the search text field
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// _searchWeather: Called when user taps the search button
  /// This triggers the entire data flow!
  void _searchWeather() {
    final cityName = _searchController.text.trim();
    if (cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    // Send the event to the BLoC
    // This triggers: _onFetchWeatherRequested → API call → states
    context.read<WeatherBloc>().add(FetchWeatherRequested(cityName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Finder')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            /// Search Box: User enters a city name
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name (e.g., London, Tokyo)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchWeather,
                ),
              ),
              onSubmitted: (_) => _searchWeather(),
            ),
            const SizedBox(height: AppSpacing.lg),

            /// BlocBuilder: Rebuilds based on BLoC state
            ///
            /// This is the KEY to reactive UI!
            /// Whenever the WeatherBloc emits a new state,
            /// this builder is called with that state.
            ///
            /// We check what state we're in and display appropriate UI:
            /// - Initial/Loading: Show spinner
            /// - Loaded: Show weather data
            /// - Error: Show error message
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  /// Check the state type and display accordingly
                  if (state is WeatherInitial) {
                    // No search yet - show welcome message
                    return const Center(
                      child: Text(
                        'Search for a city to see its weather',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  } else if (state is WeatherLoading) {
                    // API call in progress - show spinner
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is WeatherError) {
                    // Error - show error message and retry button
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: _searchWeather,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is WeatherLoaded) {
                    // Success - display weather data
                    final weather = state.weather;
                    return _buildWeatherDisplay(weather);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// _buildWeatherDisplay: Displays the weather data in a nice card
  Widget _buildWeatherDisplay(dynamic weather) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // City name header
          Text(
            weather.city,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weather card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature row
                  Row(
                    children: [
                      const Icon(
                        Icons.thermostat,
                        size: 32,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Temperature'),
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg * 2),

                  // Description
                  Row(
                    children: [
                      const Icon(
                        Icons.cloud,
                        size: 32,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Condition'),
                          Text(
                            weather.description,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg * 2),

                  // Humidity
                  Row(
                    children: [
                      const Icon(
                        Icons.opacity,
                        size: 32,
                        color: Colors.cyan,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Humidity'),
                          Text(
                            '${weather.humidity.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg * 2),

                  // Wind Speed
                  Row(
                    children: [
                      const Icon(
                        Icons.air,
                        size: 32,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wind Speed'),
                          Text(
                            '${weather.windSpeed.toStringAsFixed(1)} km/h',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
