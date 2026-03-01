import '../../domain/entities/phone_number.dart';

/// Phone Validation States: The UI state of phone validation
///
/// States represent what the UI should display:
/// - PhoneValidationInitial: Field is empty, no validation yet
/// - PhoneValidationResult: Field has text, shows valid or invalid indicator
///
/// The BLoC emits states
/// The UI listens to states and rebuilds accordingly
abstract class PhoneValidationState {
  const PhoneValidationState();
}

/// Initial state when the field is empty
/// The UI should show the input field without any indicator
///
/// This is different from PhoneValidationResult(PhoneNumber(value: '', isValid: false))
/// because we explicitly want to distinguish between:
/// - "No input yet" (Initial)
/// - "Input is invalid" (Result with isValid: false)
class PhoneValidationInitial extends PhoneValidationState {
  const PhoneValidationInitial();
}

/// The field has text and validation is complete
/// The state holds the PhoneNumber entity with both value and isValid flag
///
/// The UI reads this state to decide:
/// - If isValid: show green "Valid phone number" with checkmark
/// - If not isValid: show red "Invalid phone number" with X
///
/// The PhoneNumber entity contains:
/// - value: what the user typed (e.g., "+5511999999999")
/// - isValid: whether it passed validation (true/false)
class PhoneValidationResult extends PhoneValidationState {
  final PhoneNumber phoneNumber;

  /// Constructor: Hold the validation result
  const PhoneValidationResult(this.phoneNumber);
}
