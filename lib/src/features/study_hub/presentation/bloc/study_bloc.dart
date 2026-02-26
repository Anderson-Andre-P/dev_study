import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/study.dart';
import '../../domain/usecases/get_studies.dart';
import '../pages/layout_study_page.dart';
import '../pages/study_home_page.dart';
import 'study_event.dart';
import 'study_state.dart';

class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final GetStudies _getStudies;

  StudyBloc(this._getStudies) : super(const StudyInitial()) {
    on<StudyLoadRequested>(_onStudyLoadRequested);
  }

  Future<void> _onStudyLoadRequested(
    StudyLoadRequested event,
    Emitter<StudyState> emit,
  ) async {
    emit(const StudyLoading());
    try {
      final studies = await _getStudies();
      final items = studies.map(_toViewModel).toList();
      emit(StudyLoaded(items));
    } catch (e) {
      emit(StudyError(e.toString()));
    }
  }

  StudyItemView _toViewModel(Study study) {
    final icon = switch (study.icon) {
      'grid' => Icons.grid_view_rounded,
      'animation' => Icons.animation_outlined,
      'sync_alt' => Icons.sync_alt_outlined,
      _ => Icons.help_outline,
    };

    return StudyItemView(
      title: study.title,
      description: study.description,
      icon: icon,
      pageBuilder: (_) => const LayoutStudyPage(),
    );
  }
}
