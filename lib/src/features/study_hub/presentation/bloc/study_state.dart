import '../pages/study_home_page.dart';

/// States represent the UI state at any given moment in the BLoC.
/// In clean architecture, states are the OUTPUT from the presentation layer.
/// The UI listens to state changes and rebuilds widgets accordingly.
///
/// State Management Flow:
/// StudyLoadRequested event → BLoC processes event → emits StudyLoading state
/// → UI shows spinner → BLoC fetches data from domain layer → emits StudyLoaded state
/// → UI displays the data
abstract class StudyState {
  const StudyState();
}

/// StudyInitial: The starting state when the BLoC is first created.
/// The UI hasn't requested any data yet.
/// Typically shown when the screen first opens.
class StudyInitial extends StudyState {
  const StudyInitial();
}

/// StudyLoading: Emitted while the BLoC is fetching data from the domain layer.
/// The UI should show a loading spinner during this state.
/// This indicates an async operation is in progress.
class StudyLoading extends StudyState {
  const StudyLoading();
}

/// StudyLoaded: Emitted after the BLoC successfully fetches studies from the domain layer.
/// Contains the list of StudyItemView objects ready to display.
/// The UI displays the GridView of study cards in this state.
class StudyLoaded extends StudyState {
  final List<StudyItemView> items;

  const StudyLoaded(this.items);
}

/// StudyError: Emitted when something goes wrong during data fetching.
/// Contains an error message to display to the user.
/// The UI shows an error message and a "Retry" button in this state.
class StudyError extends StudyState {
  final String message;

  const StudyError(this.message);
}
