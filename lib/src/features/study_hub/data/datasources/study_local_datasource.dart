/// DATA LAYER - DATASOURCE
///
/// StudyLocalDataSource is responsible for FETCHING RAW DATA.
///
/// What is it?
/// - The lowest layer in clean architecture
/// - Handles data retrieval (from database, API, files, etc.)
/// - Returns raw data structures (Maps, not domain entities)
///
/// In this project:
/// - This datasource returns hardcoded data (simulating a database)
/// - In a real app, this would fetch from:
///   * SQLite database
///   * REST API (using http package)
///   * GraphQL API
///   * Firebase
///   * Local JSON files
///
/// Data Flow:
/// StudyLocalDataSource.fetch() returns raw Map data
///       ↓
/// StudyRepositoryImpl converts Maps to Study domain entities
///       ↓
/// GetStudies usecase returns List of Study
///       ↓
/// StudyBloc transforms to StudyItemView for UI
///       ↓
/// StudyHomePage displays the data
class StudyLocalDataSource {
  /// fetch(): Gets all study data
  ///
  /// Why Future?
  /// - Real data fetching (API, database) takes time
  /// - Future allows async/await
  /// - Even fake data uses Future for consistency
  ///
  /// Why Map instead of Study entity?
  /// - Raw data from datasource is unstructured
  /// - Maps represent flexible data
  /// - Repository layer converts to structured domain entities
  /// - This keeps domain layer independent of data source format
  Future<List<Map<String, dynamic>>> fetch() async {
    /// In a real app, this might be:
    /// - Database query: await database.query('studies')
    /// - API call: await http.get('api.com/studies')
    /// - JSON file: jsonDecode(await rootBundle.loadString('assets/studies.json'))
    ///
    /// For learning purposes, we return hardcoded data
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
      {
        'title': 'State Management',
        'description': 'Comparisons between approaches',
        'icon': 'sync_alt',
      },
      {
        'title': 'Weather API',
        'description': 'HTTP API consumption with the http package',
        'icon': 'cloud',
      },
    ];
  }
}
