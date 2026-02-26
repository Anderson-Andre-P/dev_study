import 'package:dev_study/src/features/study_hub/domain/entities/study.dart';

abstract class StudyRepository {
  Future<List<Study>> getStudies();
}
