import 'package:dev_study/src/features/counter/data/datasources/counter_local_datasource.dart';
import 'package:dev_study/src/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:dev_study/src/features/counter/domain/usecases/decrement_counter.dart';
import 'package:dev_study/src/features/counter/domain/usecases/increment_counter.dart';
import 'package:dev_study/src/features/counter/domain/usecases/reset_counter.dart';
import 'package:dev_study/src/features/counter/presentation/bloc/counter_bloc.dart';
import 'package:dev_study/src/features/study_hub/data/datasources/study_local_datasource.dart';
import 'package:dev_study/src/features/study_hub/data/repositories/study_repository_impl.dart';
import 'package:dev_study/src/features/timer/data/datasources/timer_datasource.dart';
import 'package:dev_study/src/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:dev_study/src/features/timer/domain/usecases/pause_timer.dart';
import 'package:dev_study/src/features/timer/domain/usecases/resume_timer.dart';
import 'package:dev_study/src/features/timer/domain/usecases/start_timer.dart';
import 'package:dev_study/src/features/timer/domain/usecases/stop_timer.dart';
import 'package:dev_study/src/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:dev_study/src/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:dev_study/src/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:dev_study/src/features/weather/domain/usecases/get_weather_by_city.dart';
import 'package:dev_study/src/features/weather/presentation/bloc/weather_bloc.dart';

import '../features/study_hub/domain/usecases/get_studies.dart';
import '../features/study_hub/presentation/bloc/study_bloc.dart';

/// DEPENDENCY INJECTION (DI) - The Glue That Connects Clean Architecture Layers
///
/// What is Dependency Injection?
/// Instead of each class creating its own dependencies (like "new"), we provide
/// them from outside. This makes code testable and flexible.
///
/// Without DI (Bad):
/// ```
///   class StudyBloc {
///     final GetStudies getStudies = GetStudies(StudyRepositoryImpl(...)); // Creates its own
///   }
/// ```
///
/// With DI (Good):
/// ```
///   class StudyBloc {
///     final GetStudies getStudies; // Receives as parameter
///     StudyBloc(this.getStudies);
///   }
/// ```
///
/// Why is this file important?
/// - Central place where all layers are connected
/// - Easy to swap implementations (real vs mock/test data)
/// - Shows the architecture flow clearly
///
/// The Dependency Chain (from bottom to top):
/// StudyLocalDataSource (fetches raw data)
///       ↓ (provides data to)
/// StudyRepositoryImpl (implements the repository interface)
///       ↓ (used by)
/// GetStudies usecase (business logic)
///       ↓ (injected into)
/// StudyBloc (state management)
///       ↓ (used by)
/// main.dart via BlocProvider (UI layer)
StudyBloc createStudyBloc() {
  /// Build the dependency chain layer by layer:

  /// Layer 1 - DATA: StudyLocalDataSource
  /// This is where raw data comes from (database, API, local cache, etc.)
  /// In this case: hardcoded list in memory
  final dataSource = StudyLocalDataSource();

  /// Layer 2 - DATA: StudyRepositoryImpl
  /// Implements the StudyRepository interface from domain layer
  /// Transforms raw data from datasource into domain entities (Study)
  final repository = StudyRepositoryImpl(dataSource);

  /// Layer 3 - DOMAIN: GetStudies usecase
  /// Contains business logic: "Get all studies"
  /// Independent of any framework - could be used in web, desktop, CLI apps
  final getStudies = GetStudies(repository);

  /// Layer 4 - PRESENTATION: StudyBloc
  /// Uses the domain usecase to fetch data
  /// Manages state and emits updates to the UI
  final bloc = StudyBloc(getStudies);

  return bloc;
}

/// TESTING EXAMPLE (This is why DI is powerful):
///
/// In a test file, you could do:
/// ```
///   class FakeDataSource extends StudyLocalDataSource {
///     @override
///     Future<List<Map<String, dynamic>>> fetch() async {
///       return [/* test data */];
///     }
///   }
///
///   final bloc = StudyBloc(
///     GetStudies(StudyRepositoryImpl(FakeDataSource()))
///   );
/// ```
///
/// The StudyBloc works with fake data - no API calls, no database!
/// This is why separation of concerns matters: you can test each layer independently.

/// ============================================================================
/// WEATHER FEATURE - Demonstrates HTTP API consumption
/// ============================================================================

/// Same pattern as StudyBloc, but with HTTP API calls instead of local data
WeatherBloc createWeatherBloc() {
  /// Layer 1 - DATA: WeatherRemoteDataSource
  /// This is where we make HTTP requests to the API
  /// Uses the `http` package to fetch real weather data
  final dataSource = WeatherRemoteDataSource();

  /// Layer 2 - DATA: WeatherRepositoryImpl
  /// Takes raw JSON from API and transforms to domain entities
  final repository = WeatherRepositoryImpl(dataSource);

  /// Layer 3 - DOMAIN: GetWeatherByCity usecase
  /// Business logic: "Get weather for a city"
  final getWeatherByCity = GetWeatherByCity(repository);

  /// Layer 4 - PRESENTATION: WeatherBloc
  /// Orchestrates the weather feature
  final bloc = WeatherBloc(getWeatherByCity);

  return bloc;
}

/// ============================================================================
/// COUNTER FEATURE - Demonstrates simple BLoC state management
/// ============================================================================

/// Same clean architecture pattern, but with in-memory data (no API)
CounterBloc createCounterBloc() {
  /// Layer 1 - DATA: CounterLocalDataSource
  /// Stores counter value in memory
  final dataSource = CounterLocalDataSource();

  /// Layer 2 - DATA: CounterRepositoryImpl
  /// Transforms raw int to Counter domain entity
  final repository = CounterRepositoryImpl(dataSource);

  /// Layer 3 - DOMAIN: Three usecases for different operations
  final incrementCounter = IncrementCounter(repository);
  final decrementCounter = DecrementCounter(repository);
  final resetCounter = ResetCounter(repository);

  /// Layer 4 - PRESENTATION: CounterBloc
  /// Handles all counter operations
  final bloc = CounterBloc(
    incrementCounter,
    decrementCounter,
    resetCounter,
  );

  return bloc;
}

/// ============================================================================
/// TIMER FEATURE - Demonstrates stream management with BLoC
/// ============================================================================

/// Same clean architecture pattern, but with stream-based state updates
TimerBloc createTimerBloc() {
  /// Layer 1 - DATA: TimerDataSource
  /// Manages timer stream using Timer.periodic and StreamController
  /// Handles timer ticks, pause, resume, and stop operations
  final dataSource = TimerDataSource();

  /// Layer 2 - DATA: TimerRepositoryImpl
  /// Implements TimerRepository interface
  /// Provides methods to start, pause, resume, stop timer
  final repository = TimerRepositoryImpl(dataSource);

  /// Layer 3 - DOMAIN: Four usecases for different timer operations
  /// Each usecase encapsulates a single business operation
  final startTimer = StartTimer(repository);
  final pauseTimer = PauseTimer(repository);
  final resumeTimer = ResumeTimer(repository);
  final stopTimer = StopTimer(repository);

  /// Layer 4 - PRESENTATION: TimerBloc
  /// Orchestrates timer operations and manages state
  /// Listens to the timer stream and emits state changes
  final bloc = TimerBloc(
    startTimer,
    pauseTimer,
    resumeTimer,
    stopTimer,
    repository,
  );

  return bloc;
}
