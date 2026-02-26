import '../pages/study_home_page.dart';

abstract class StudyState {
  const StudyState();
}

class StudyInitial extends StudyState {
  const StudyInitial();
}

class StudyLoading extends StudyState {
  const StudyLoading();
}

class StudyLoaded extends StudyState {
  final List<StudyItemView> items;

  const StudyLoaded(this.items);
}

class StudyError extends StudyState {
  final String message;

  const StudyError(this.message);
}
