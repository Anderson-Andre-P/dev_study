/// Phone Validation Events: User actions on the phone input field
///
/// Events represent what the user does:
/// - User types something → PhoneNumberChanged event
/// - User clears the field → PhoneNumberChanged with empty string
///
/// The UI sends events to the BLoC
/// The BLoC processes them and emits new states
abstract class PhoneValidationEvent {
  const PhoneValidationEvent();
}

/// User typed or changed the phone number field
/// Fired on every keystroke (or paste)
///
/// Real-time validation means validating as the user types.
/// This event carries the current text in the field.
class PhoneNumberChanged extends PhoneValidationEvent {
  final String phone;

  /// Constructor: Store the phone string from the text field
  const PhoneNumberChanged(this.phone);
}
