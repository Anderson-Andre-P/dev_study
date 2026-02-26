import '../../domain/entities/study.dart';
import '../../domain/repositories/study_repository.dart';
import '../datasources/study_local_datasource.dart';
import '../models/study_model.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyLocalDataSource datasource;

  StudyRepositoryImpl(this.datasource);

  @override
  Future<List<Study>> getStudies() async {
    final raw = await datasource.fetch();
    return raw.map(StudyModel.fromMap).toList();
  }
}
