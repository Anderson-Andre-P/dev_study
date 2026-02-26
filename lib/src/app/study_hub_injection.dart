import 'package:dev_study/src/features/study_hub/data/datasources/study_local_datasource.dart';
import 'package:dev_study/src/features/study_hub/data/repositories/study_repository_impl.dart';

import '../features/study_hub/domain/usecases/get_studies.dart';
import '../features/study_hub/presentation/bloc/study_bloc.dart';

StudyBloc createStudyBloc() {
  return StudyBloc(
    GetStudies(StudyRepositoryImpl(StudyLocalDataSource())),
  );
}
