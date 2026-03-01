/// PhoneValidationDataSource: The validation implementation
///
/// This is the lowest layer - where the actual validation happens.
/// It takes a phone number string and returns true/false.
///
/// In this case: validates US phone numbers only
/// - Only accepts 10 digits (area code + 7-digit number)
/// - Input formatter handles the mask: (XXX) XXX-XXXX
/// - Only digits allowed in input
///
/// In a real app, this might:
/// - Call an external API
/// - Check a database of valid numbers
/// - Support multiple countries
///
/// The datasource returns raw data (bool)
/// The repository wraps it in a domain entity (PhoneNumber)
class PhoneValidationDataSource {
  /// Validate a US phone number
  ///
  /// Requirements:
  /// - Exactly 10 digits (no formatting characters expected)
  /// - Format: XXX-XXX-XXXX (stored without formatting)
  /// - Valid area codes: typically 200-999 (some are reserved, but we validate any 3-digit code)
  ///
  /// Valid examples (10 digits, formatted display as (XXX) XXX-XXXX):
  /// - 5551234567 → displays as (555) 123-4567
  /// - 2125552000 → displays as (212) 555-2000
  /// - 4105551234 → displays as (410) 555-1234
  ///
  /// Invalid examples:
  /// - 123 (too short)
  /// - 555123456789 (too long)
  /// - abc (not numeric)
  /// - 555-123-4567 (has formatting - should be stripped by input formatter)
  Future<bool> validate(String phone) async {
    /// In a real app, this might be async:
    /// - Calling an API to verify the number is active
    /// - Database lookup to check if already registered
    /// - Validation service call
    ///
    /// Here we use Future to maintain consistency with the architecture
    /// The UI doesn't know this is synchronous

    // Remove any non-digit characters (shouldn't exist with proper input formatter, but be safe)
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // US phone numbers must be exactly 10 digits
    if (digitsOnly.length != 10) {
      return false;
    }

    // All characters must be digits
    if (!RegExp(r'^\d{10}$').hasMatch(digitsOnly)) {
      return false;
    }

    return true;
  }
}
