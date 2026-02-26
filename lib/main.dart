import 'package:dev_study/src/app/study_hub_injection.dart';
import 'package:dev_study/src/features/study_hub/presentation/bloc/study_bloc.dart';
import 'package:dev_study/src/features/study_hub/presentation/pages/study_home_page.dart';
import 'package:dev_study/src/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      home: BlocProvider<StudyBloc>(
        create: (_) => createStudyBloc(),
        child: const StudyHomePage(),
      ),
    );
  }
}
