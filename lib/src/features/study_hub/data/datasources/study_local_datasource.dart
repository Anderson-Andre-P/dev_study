class StudyLocalDataSource {
  Future<List<Map<String, dynamic>>> fetch() async {
    return [
      {
        'title': 'Layouts',
        'description': 'Experiments with UI composition',
        'icon': 'grid',
      },
      {
        'title': 'Animations',
        'description': 'Animation test',
        'icon': 'animation',
      },
    ];
  }
}
