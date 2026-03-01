import '../../domain/entities/phone_number.dart';
import '../../domain/repositories/phone_validation_repository.dart';
import '../datasources/phone_validation_datasource.dart';

/// PhoneValidationRepositoryImpl: Implements the PhoneValidationRepository interface
///
/// This is the bridge between the domain layer and the data layer.
/// It takes raw data from the datasource and transforms it into domain entities.
///
/// Responsibility:
/// - Call the datasource for raw validation data (bool)
/// - Wrap the bool in a PhoneNumber entity
/// - Return the entity to the domain layer
///
/// This keeps the domain layer independent of how validation is done.
/// If we change from regex to API validation, only this file changes.
class PhoneValidationRepositoryImpl implements PhoneValidationRepository {
  final PhoneValidationDataSource _dataSource;

  /// Constructor: Takes a datasource as dependency
  /// The datasource is injected, not created here
  /// This makes testing easy: pass a fake datasource in tests
  const PhoneValidationRepositoryImpl(this._dataSource);

  @override
  Future<PhoneNumber> validate(String phone) async {
    /// Get the raw validation result from the datasource
    /// This just returns true or false
    final isValid = await _dataSource.validate(phone);

    /// Transform the raw data into a domain entity
    /// The domain layer doesn't care about datasource details
    /// It just knows it got a PhoneNumber with a value and validity
    return PhoneNumber(
      value: phone,
      isValid: isValid,
    );
  }
}
