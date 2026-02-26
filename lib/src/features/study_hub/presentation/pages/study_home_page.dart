import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../bloc/study_bloc.dart';
import '../bloc/study_event.dart';
import '../bloc/study_state.dart';
import '../widgets/study_card.dart';

/// StudyHomePage: The UI layer that displays the list of study items.
///
/// In clean architecture, this is the PRESENTATION LAYER:
///
///   UI Layer (This file) - What users see and interact with
///       |
///       |-- Sends events to BLoC (e.g., "Load studies")
///       |-- Listens to state changes from BLoC
///       |-- Rebuilds widgets when state changes
///
/// Key Concepts:
/// - This page is STATEFUL because it needs to trigger loading in initState()
/// - It uses BlocBuilder to rebuild when BLoC state changes
/// - It NEVER directly calls domain logic - only the BLoC does
/// - It's reactive: responds to state changes, doesn't manage logic
class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  /// initState: Called once when the widget is first created.
  /// This is where we trigger the data loading.
  ///
  /// Flow:
  /// 1. Page is created
  /// 2. initState() is called
  /// 3. We send StudyLoadRequested event to the BLoC
  /// 4. BLoC receives event and starts fetching data
  /// 5. BLoC emits states (Loading → Loaded/Error)
  /// 6. UI rebuilds in response to state changes
  @override
  void initState() {
    super.initState();
    // Get the BLoC from the widget tree and tell it to load studies
    // context.read() finds the StudyBloc above this widget
    context.read<StudyBloc>().add(const StudyLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Study Hub')),

      /// BlocBuilder: Rebuilds the body widget whenever the StudyBloc state changes.
      /// This is the key to reactive UI in BLoC pattern:
      /// - When state is StudyLoading: shows spinner
      /// - When state is StudyLoaded: shows grid of cards
      /// - When state is StudyError: shows error message
      ///
      /// Without BloC: You'd manually update state and call setState()
      /// With BLoC: You just listen to state changes - much cleaner!
      body: BlocBuilder<StudyBloc, StudyState>(
        builder: (context, state) {
          /// Check what state we're in and display appropriate UI
          if (state is StudyLoading || state is StudyInitial) {
            // Initial or loading: Show spinner while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudyError) {
            // Error: Show error message and retry button
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: AppSpacing.md),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    /// Retry button: Send StudyLoadRequested again
                    /// This lets user retry after an error without restarting the app
                    onPressed: () {
                      context.read<StudyBloc>().add(const StudyLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is StudyLoaded) {
            // Success: Display the grid of study cards
            // state.items contains the transformed data from the BLoC
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) => StudyCard(item: state.items[index]),
            );
          }
          // Fallback: Show spinner (shouldn't reach here)
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
