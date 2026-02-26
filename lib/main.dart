import 'package:dev_study/src/features/study_hub/presentation/pages/study_home_page.dart';
import 'package:dev_study/src/features/study_hub/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StudyHomePage(),
    );
  }
}
