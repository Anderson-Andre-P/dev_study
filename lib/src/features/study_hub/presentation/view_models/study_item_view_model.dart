import 'package:flutter/material.dart';

/// StudyItemView: A MODEL class that represents a study item in the UI.
///
/// Why a separate model?
/// - Domain layer has Study (database structure)
/// - UI needs StudyItemView (with IconData and navigation)
/// - This prevents mixing concerns: domain doesn't know about UI widgets
///
/// In clean architecture:
/// Domain Entity (Study) → Transformed to → UI Model (StudyItemView)
///                             by BLoC
/// This transformation happens in StudyBloc._toViewModel()
class StudyItemView {
  final String title;
  final String description;
  final IconData icon;

  /// pageBuilder: A lambda function that creates the page when card is tapped
  /// This is how navigation is handled: BLoC creates the page to navigate to
  final WidgetBuilder pageBuilder;

  const StudyItemView({
    required this.title,
    required this.description,
    required this.icon,
    required this.pageBuilder,
  });
}
