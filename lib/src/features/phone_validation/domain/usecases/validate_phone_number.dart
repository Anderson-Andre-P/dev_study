import '../entities/phone_number.dart';
import '../repositories/phone_validation_repository.dart';

/// ValidatePhoneNumber Usecase: Business logic for phone validation
///
/// This usecase encapsulates a single, well-defined business operation:
/// "Validate a phone number"
///
/// The BLoC calls this usecase. The usecase calls the repository.
/// The repository calls the datasource.
/// Results flow back up through the same path.
///
/// Why a separate usecase class?
/// - Encapsulates the operation in a reusable way
/// - Easy to test the business logic
/// - Domain layer can be used in CLI, web, or desktop apps
/// - If validation rules change, you change ONE place
///
/// Example of changing business logic:
/// - Add country code support
/// - Add formatting
/// - Add blacklist checking
/// All in this ONE class, without touching UI or data layers
class ValidatePhoneNumber {
  final PhoneValidationRepository _repository;

  /// Constructor: Takes the repository as a dependency
  /// This is Dependency Injection - the usecase doesn't create its own repository
  const ValidatePhoneNumber(this._repository);

  /// Call the usecase with a phone number string
  /// Returns a PhoneNumber entity with validation result
  Future<PhoneNumber> call(String phone) async {
    return await _repository.validate(phone);
  }
}
