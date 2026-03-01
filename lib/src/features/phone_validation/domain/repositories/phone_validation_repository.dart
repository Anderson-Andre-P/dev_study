import '../entities/phone_number.dart';

/// PhoneValidationRepository: Interface for phone validation data access
///
/// This is the domain layer interface that says:
/// "I need a service that can validate phone numbers"
///
/// The data layer implements this interface and provides the actual validation logic.
///
/// Why an abstract repository?
/// - The domain layer doesn't care HOW validation works
/// - It could use regex, API calls, or other methods
/// - Easy to test: just provide a fake implementation
/// - Easy to change: swap the implementation without touching domain logic
abstract class PhoneValidationRepository {
  /// Validate a phone number string
  ///
  /// Takes a raw phone string and returns a PhoneNumber entity
  /// containing both the original value and validation result
  Future<PhoneNumber> validate(String phone);
}
