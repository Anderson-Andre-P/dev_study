# Weather API Integration Guide

This guide explains how the Weather feature demonstrates real HTTP API consumption while maintaining clean architecture principles.

## What This Feature Demonstrates

The Weather feature shows:

1. **HTTP Requests** using the `http` package
2. **JSON Parsing** from API responses
3. **Error Handling** (network errors, invalid input, API errors)
4. **Async Operations** (waiting for API responses)
5. **Clean Architecture** applied to real-world API data
6. **Dependency Injection** for testable code

## The Weather API

This feature uses **Open-Meteo** - a free weather API requiring no API key.

### API Documentation

- **Geocoding API**: Find city coordinates
  - URL: `https://geocoding-api.open-meteo.com/v1/search`
  - Query: `?name=London&count=1&format=json`
  - Returns: List of matching cities with latitude/longitude

- **Weather API**: Get weather for coordinates
  - URL: `https://api.open-meteo.com/v1/forecast`
  - Query: `?latitude=51.5&longitude=-0.1&current=temperature_2m,humidity...`
  - Returns: Current weather data

### Why Two APIs?

Users search by city name (text), but weather APIs need coordinates (lat/long).
So we first geocode the city name to coordinates, then get the weather.

---

## How HTTP Requests Work

### The `http` Package

```dart
import 'package:http/http.dart' as http;

// Make a GET request
final response = await http.get(Uri.parse('https://api.example.com/data'));

// Check the status code
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  // Use the data
}
```

### Response Structure

```dart
http.Response {
  statusCode: 200,              // HTTP status code (200 = success)
  body: '{"city": "London"}',   // Raw JSON as string
  headers: {...},               // Response headers
}
```

---

## Architecture Flow for Weather Feature

### Layer by Layer

```
┌─────────────────────────────────────┐
│ UI LAYER: WeatherPage              │
│ - TextField for city input          │
│ - BlocBuilder listening to states   │
│ - Shows loading/error/success       │
└──────────────┬──────────────────────┘
               │ sends FetchWeatherRequested event
               ↓
┌─────────────────────────────────────┐
│ PRESENTATION: WeatherBloc           │
│ - Listens for FetchWeatherRequested │
│ - Calls domain usecase              │
│ - Emits WeatherLoading state        │
│ - Catches errors → emits Error state│
└──────────────┬──────────────────────┘
               │ calls get weather
               ↓
┌─────────────────────────────────────┐
│ DOMAIN: GetWeatherByCity Usecase    │
│ - Business logic (none for now)     │
│ - Delegates to repository           │
└──────────────┬──────────────────────┘
               │ calls
               ↓
┌─────────────────────────────────────┐
│ DATA: WeatherRepositoryImpl          │
│ - Takes raw API data (Map)          │
│ - Transforms to Weather entity      │
│ - Returns to domain layer           │
└──────────────┬──────────────────────┘
               │ uses
               ↓
┌─────────────────────────────────────┐
│ DATA: WeatherRemoteDataSource       │
│ - Makes HTTP requests               │
│ - Parses JSON responses             │
│ - Returns raw Map data              │
└──────────────┬──────────────────────┘
               │
               ↓
        [Real API]
   Open-Meteo Weather
```

---

## Code Walkthrough

### 1. Making the HTTP Request

**File**: `weather_remote_datasource.dart`

```dart
final geoResponse = await _httpClient.get(Uri.parse(geoUrl));

if (geoResponse.statusCode != 200) {
  throw Exception('City not found');
}

// Parse JSON response
final geoData = jsonDecode(geoResponse.body) as Map<String, dynamic>;
```

**Key Points**:

- `http.get()` is async (returns Future)
- Always check `statusCode` first
- `jsonDecode()` converts JSON string to Dart Map
- Errors are thrown and caught by BLoC

### 2. Transforming API Data

The API returns:

```json
{
  "current": {
    "temperature_2m": 22.5,
    "relative_humidity_2m": 65,
    "weather_code": 0,
    "wind_speed_10m": 10.2
  }
}
```

We transform to:

```dart
Weather(
  city: "London",
  temperature: 22.5,
  description: "Sunny",
  humidity: 65.0,
  windSpeed: 10.2,
)
```

**Why transform?**

- API data is fragile (might change)
- Domain entities are stable
- Separation of concerns

### 3. Error Handling

```dart
try {
  final weather = await _getWeatherByCity(cityName);
  emit(WeatherLoaded(weather));
} catch (e) {
  emit(WeatherError('Failed to fetch weather: ${e.toString()}'));
}
```

**Errors can occur at**:

- **Network**: No internet, timeout
- **Datasource**: City not found, API error
- **Parsing**: Malformed JSON
- All bubble up through the BLoC

### 4. UI Response

```dart
BlocBuilder<WeatherBloc, WeatherState>(
  builder: (context, state) {
    if (state is WeatherLoading) {
      return CircularProgressIndicator(); // Show spinner
    } else if (state is WeatherError) {
      return ErrorWidget(state.message); // Show error
    } else if (state is WeatherLoaded) {
      return WeatherDisplay(state.weather); // Show data
    }
  }
)
```

---

## Testing the Feature

### Test with Real Cities

Try searching for:

- **London** - Major city, should work
- **Tokyo** - Different timezone
- **New York** - Has multiple matches (API returns first)
- **xyz123** - Non-existent city (should error)

### Expected Behavior

1. **Typing a city**: No API call yet
2. **Tapping search**: Loading spinner appears
3. **API responds**: Weather data displays (2-3 seconds)
4. **Error**: Error message shows with retry button

### Network Debugging

If you want to see the actual HTTP requests and responses:

```dart
// In WeatherRemoteDataSource
print('Request URL: $geoUrl');
print('Response: ${geoResponse.body}');
print('Status: ${geoResponse.statusCode}');
```

---

## How It Connects to Clean Architecture

### Why Each Layer?

| Layer  | Why              | What If Removed                   |
| ------ | ---------------- | --------------------------------- |
| UI     | User interaction | App wouldn't be interactive       |
| BLoC   | State management | UI couldn't respond to async data |
| Domain | Business logic   | Logic coupled to UI/API           |
| Data   | Data access      | Domain dependent on API structure |

### Real-World Example

**Scenario**: Your company switches weather APIs from Open-Meteo to WeatherAPI.com

**With Clean Architecture**:

- Only modify `WeatherRemoteDataSource` (datasource)
- Rest of app stays the same
- Takes 10 minutes

**Without Clean Architecture**:

- Modify UI, BLoC, domain, repository
- Risk breaking everything
- Takes hours

This is why architecture matters! 🎯

---

## Data Flow: Step by Step

### User searches for "London"

```
1. User types "London" in TextField
   └─→ _searchController.text = "London"

2. User taps Search button
   └─→ _searchWeather() is called
   └─→ context.read<WeatherBloc>().add(FetchWeatherRequested("London"))

3. BLoC receives FetchWeatherRequested event
   └─→ emit(WeatherLoading())
   └─→ UI shows spinner

4. BLoC calls _getWeatherByCity("London")
   └─→ WeatherBloc._onFetchWeatherRequested()

5. Usecase calls repository.getWeatherByCity("London")
   └─→ GetWeatherByCity.call()

6. Repository calls datasource.getWeatherByCity("London")
   └─→ WeatherRepositoryImpl.getWeatherByCity()

7. Datasource makes HTTP request
   └─→ WeatherRemoteDataSource.getWeatherByCity()
   └─→ http.get("https://geocoding-api.open-meteo.com/v1/search?name=London...")
   └─→ Response received: {"results": [{"latitude": 51.5, "longitude": -0.1, ...}]}

8. Datasource gets coordinates
   └─→ latitude = 51.5, longitude = -0.1

9. Datasource makes second HTTP request for weather
   └─→ http.get("https://api.open-meteo.com/v1/forecast?latitude=51.5...")
   └─→ Response received: {"current": {"temperature_2m": 15.2, ...}}

10. Datasource transforms raw data to Map
    └─→ return {'city': 'London', 'temperature': 15.2, 'description': 'Cloudy', ...}

11. Repository transforms Map to Weather entity
    └─→ return Weather(city: 'London', temperature: 15.2, ...)

12. Usecase returns Weather to BLoC
    └─→ GetWeatherByCity returns Weather

13. BLoC receives Weather
    └─→ emit(WeatherLoaded(weather))
    └─→ UI rebuilds

14. BlocBuilder detects new state
    └─→ Calls builder with WeatherLoaded state

15. UI displays weather
    └─→ Shows city name, temperature, humidity, wind speed
```

That's 15 steps to show "London: 15.2°C"!

But notice:

- Each step is simple
- Each layer has one responsibility
- Easy to test each step independently
- Easy to replace any component

---

## Debugging Tips

### Issue: API returns 404

**Check**:

- Is the URL correct? (Print it)
- Is the city name correct?
- Try a different city

### Issue: JSON parsing error

**Check**:

- What does the API actually return? (Print `geoResponse.body`)
- Are the field names correct? ('temperature_2m' not 'temperature')

### Issue: Slow response

**Check**:

- Network speed (mobile data is slower)
- API response time
- Add timeout: `timeout: Duration(seconds: 10)`

### Issue: Empty results

**Check**:

- City name might be misspelled
- API returns empty results for non-existent cities
- Check that `results` list isn't empty

---

## Extending the Feature

### Add Caching

```dart
// Store in local database
// If request fails, show cached data
```

### Add Multiple Cities

```dart
// Show list of cities user searched
// Allow comparing weather
```

### Add Forecast

```dart
// Show 7-day forecast
// Add charts for temperature trends
```

### Add Favorites

```dart
// Save favorite cities
// Quick access to recent searches
```

---

## Key Concepts Recap

1. **http.get()** - Makes HTTP request, returns Future
2. **jsonDecode()** - Converts JSON string to Dart Map
3. **statusCode** - Always check if request succeeded (200 = success)
4. **Error handling** - Errors in datasource → caught by BLoC → shown to user
5. **Transformation** - Raw API data → domain entities (separation of concerns)
6. **Async/await** - API calls take time, use async/await
7. **UI responsiveness** - Show loading spinner, don't block UI

---

## Learning Checklist

- [ ] Understand how http.get() works
- [ ] Understand JSON parsing with jsonDecode()
- [ ] Trace the data flow from UI to API and back
- [ ] Understand why we transform API data to entities
- [ ] Understand error handling at each layer
- [ ] Try searching for different cities
- [ ] Print API responses to see what's being returned
- [ ] Try breaking things (empty city, invalid URL) to see errors
- [ ] Explain to someone why clean architecture helps with APIs

---

Good luck exploring APIs!
