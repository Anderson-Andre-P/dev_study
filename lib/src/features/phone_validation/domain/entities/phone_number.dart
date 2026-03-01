/// Phone Number Entity: Represents a validated phone number
///
/// This entity holds:
/// - value: The phone number string entered by the user
/// - isValid: Whether it passes validation rules
///
/// Why separate the entity from just a bool?
/// - Consistency: All features follow the same architecture
/// - Extensibility: Easy to add more fields (country code, formatted version, etc.)
/// - Clarity: Makes the intent clear - this is a phone number, not just a boolean
class PhoneNumber {
  final String value;
  final bool isValid;

  const PhoneNumber({
    required this.value,
    required this.isValid,
  });
}
