import '../../domain/entities/study.dart';
import '../../domain/usecases/get_studies.dart';

class StudyController {
  final GetStudies getStudies;

  StudyController(this.getStudies);

  Future<List<Study>> load() => getStudies();
}
