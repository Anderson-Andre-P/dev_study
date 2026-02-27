import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/study_hub_injection.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../weather/presentation/pages/weather_page.dart';
import '../../domain/entities/study.dart';
import '../../domain/usecases/get_studies.dart';
import '../pages/layout_study_page.dart';
import '../view_models/study_item_view_model.dart';
import 'study_event.dart';
import 'study_state.dart';

/// StudyBloc: The BUSINESS LOGIC LAYER for managing study list state.
///
/// In clean architecture, the BLoC sits between the UI (Presentation) and Business Logic (Domain):
///
///   UI (StudyHomePage)
///       ↓ sends events to
///   BLoC (StudyBloc) ← YOU ARE HERE
///       ↓ uses
///   Domain Layer (GetStudies usecase)
///       ↓ uses
///   Data Layer (Repository) → Database/API
///
/// What StudyBloc does:
/// 1. Listens for events (user actions like "load studies")
/// 2. Calls domain layer usecases to get data
/// 3. Transforms that data into UI-friendly format (StudyItemView)
/// 4. Emits states that the UI listens to and reacts to
///
/// Why separate these concerns?
/// - Domain logic is independent of Flutter/UI frameworks
/// - Easy to test: you can test the BLoC without building actual UI
/// - Reusable: the domain layer can be used in web, mobile, desktop apps
/// - Maintainable: changes to UI don't affect business logic
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  /// _getStudies: A domain layer usecase (Dependency Injection)
  /// This is what we use to fetch studies. The BLoC doesn't know HOW studies
  /// are fetched (from API, database, etc.) - that's the domain layer's job.
  final GetStudies _getStudies;

  /// Constructor: Takes a GetStudies usecase and initializes the BLoC
  /// - super(const StudyInitial()): Sets the initial state
  /// - `on&lt;StudyLoadRequested&gt;(...)`: Registers a handler for StudyLoadRequested events
  ///
  /// Dependency Injection: The GetStudies usecase is injected here.
  /// This means we can test the BLoC by passing a fake/mock usecase.
  StudyBloc(this._getStudies) : super(const StudyInitial()) {
    on<StudyLoadRequested>(_onStudyLoadRequested);
  }

  /// _onStudyLoadRequested: The handler that processes StudyLoadRequested events
  ///
  /// This is called whenever a StudyLoadRequested event is added to the BLoC.
  /// It's async because fetching studies from the domain layer might take time.
  ///
  /// Flow:
  /// 1. Emit StudyLoading state (UI shows spinner)
  /// 2. Call _getStudies() - this asks the domain layer for data
  /// 3. Transform each Study entity into a StudyItemView (UI model)
  /// 4. Emit StudyLoaded state with the transformed data (UI updates)
  /// 5. If error: Emit StudyError state (UI shows error message)
  Future<void> _onStudyLoadRequested(
    StudyLoadRequested event,
    Emitter<StudyState> emit,
  ) async {
    // Emit loading state first - this tells the UI to show a spinner
    emit(const StudyLoading());

    try {
      // Call the domain layer usecase to get studies
      // This is where the data actually comes from (datasource/API/database)
      final studies = await _getStudies();

      // Transform domain entities into UI models
      // Studies (domain layer) → StudyItemView (presentation layer)
      final items = studies.map(_toViewModel).toList();

      // Emit success state with the transformed data
      // The UI now has the data and can display it
      emit(StudyLoaded(items));
    } catch (e) {
      // If something goes wrong, emit an error state
      // The UI will show an error message and a retry button
      emit(StudyError(e.toString()));
    }
  }

  /// _toViewModel: Transforms Study (domain entity) → StudyItemView (UI model)
  ///
  /// Why separate transformation?
  /// - Study is from the domain layer (database-driven structure)
  /// - StudyItemView is UI-specific (needs IconData, pageBuilder)
  /// - This prevents coupling between domain and UI
  ///
  /// Icon Mapping Example:
  /// - Domain layer stores icon as: 'grid' (simple string)
  /// - UI needs: Icons.grid_view_rounded (Flutter IconData)
  /// - This method translates between them using a switch expression
  StudyItemView _toViewModel(Study study) {
    // Convert string icon names from domain layer to Flutter IconData
    // This is data transformation, not business logic
    final icon = switch (study.icon) {
      'grid' => Icons.grid_view_rounded,
      'animation' => Icons.animation_outlined,
      'sync_alt' => Icons.sync_alt_outlined,
      'cloud' => Icons.cloud_outlined,
      _ => Icons.help_outline, // Default icon if unknown
    };

    // Determine the page to navigate to based on the study type
    // Most studies go to LayoutStudyPage
    // Weather API goes to WeatherPage with its own BLoC
    late WidgetBuilder pageBuilder;

    if (study.title == 'Weather API') {
      // Special handling for Weather API study
      // Wrap WeatherPage with BlocProvider so it has access to WeatherBloc
      pageBuilder = (_) => BlocProvider<WeatherBloc>(
        create: (_) => createWeatherBloc(),
        child: const WeatherPage(),
      );
    } else {
      // All other studies use LayoutStudyPage
      pageBuilder = (_) => const LayoutStudyPage();
    }

    // Create a UI-friendly model with all necessary UI data
    // The pageBuilder lambda defines what page opens when the card is tapped
    return StudyItemView(
      title: study.title,
      description: study.description,
      icon: icon, // Transformed icon
      pageBuilder: pageBuilder, // Dynamic navigation
    );
  }
}
