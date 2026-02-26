import '../../domain/entities/study.dart';

class StudyModel extends Study {
  const StudyModel({
    required super.title,
    required super.description,
    required super.icon,
  });

  factory StudyModel.fromMap(Map<String, dynamic> map) {
    return StudyModel(
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
    );
  }
}
