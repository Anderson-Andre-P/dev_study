import 'package:dev_study/src/app/study_hub_injection.dart';
import 'package:dev_study/src/features/study_hub/presentation/bloc/study_bloc.dart';
import 'package:dev_study/src/features/study_hub/presentation/pages/study_home_page.dart';
import 'package:dev_study/src/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// APP STARTUP: Where all the architecture comes together
///
/// This file orchestrates:
/// 1. Creating the StudyBloc (dependency injection)
/// 2. Making it available to all child widgets (BlocProvider)
/// 3. Creating the root MaterialApp
void main() {
  /// main() is the app entry point
  /// It creates and runs the root widget
  runApp(const MainApp());
}

/// MainApp: The root widget of the application
///
/// Widget Tree Structure:
/// MainApp (this)
///   └─ MaterialApp (provides Material Design)
///      └─ `BlocProvider&lt;StudyBloc&gt;` (makes StudyBloc available to children)
///         └─ StudyHomePage (the first screen user sees)
///
/// Why BlocProvider here?
/// BlocProvider is a widget that:
/// - Creates the StudyBloc once at app startup
/// - Makes it available to all descendants via context.read()
/// - Closes/disposes the BLoC when it's removed from the tree
/// - Manages the lifetime of the BLoC
///
/// The WeatherBloc is created separately when navigating to the Weather page
/// This keeps things modular: each study page manages its own BLoC if needed
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      /// BlocProvider: Makes StudyBloc available to the entire widget tree
      ///
      /// Without BlocProvider:
      /// - StudyHomePage wouldn't be able to find the BLoC with context.read()
      /// - Every widget would need to pass the BLoC down as a parameter
      ///
      /// With BlocProvider:
      /// - Any descendant widget can access the BLoC via context.read()
      /// - No need to pass it down through many levels (called "prop drilling")
      ///
      /// create: Creates a new StudyBloc instance using dependency injection
      /// The lambda (_) => createStudyBloc() is called once at app startup
      home: BlocProvider<StudyBloc>(
        create: (_) => createStudyBloc(),

        /// The StudyHomePage is now "inside" the BlocProvider
        /// This means StudyHomePage can access the BLoC with:
        /// context.read<StudyBloc>()
        child: const StudyHomePage(),
      ),
    );
  }
}
