import '../repositories/study_repository.dart';
import '../entities/study.dart';

class GetStudies {
  final StudyRepository repository;

  GetStudies(this.repository);

  Future<List<Study>> call() => repository.getStudies();
}
