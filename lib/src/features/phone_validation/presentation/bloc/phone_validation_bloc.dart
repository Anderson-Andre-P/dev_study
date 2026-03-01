import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/validate_phone_number.dart';
import 'phone_validation_event.dart';
import 'phone_validation_state.dart';

/// PhoneValidationBloc: The HEART of the phone validation feature
///
/// This is where the validation happens!
/// The BLoC:
/// 1. Listens for events from the UI (every keystroke)
/// 2. Calls the domain layer usecase
/// 3. Emits new states
/// 4. The UI rebuilds based on the new state
///
/// Data Flow:
/// User types in the text field
///   ↓
/// UI sends PhoneNumberChanged event
///   ↓
/// BLoC receives event
///   ↓
/// BLoC calls ValidatePhoneNumber usecase
///   ↓
/// Usecase calls repository.validate()
///   ↓
/// Repository calls datasource.validate() (regex check)
///   ↓
/// Datasource returns true or false
///   ↓
/// Result flows back up: datasource → repository → usecase → BLoC
///   ↓
/// BLoC either emits PhoneValidationInitial (if empty)
/// Or emits PhoneValidationResult with the validation result
///   ↓
/// UI listens to state change
///   ↓
/// UI rebuilds showing valid/invalid indicator
class PhoneValidationBloc extends Bloc<PhoneValidationEvent, PhoneValidationState> {
  /// The usecase for phone validation
  /// Injected via constructor (Dependency Injection)
  final ValidatePhoneNumber _validatePhoneNumber;

  /// Constructor
  /// Takes the ValidatePhoneNumber usecase and sets initial state
  PhoneValidationBloc(this._validatePhoneNumber)
      : super(const PhoneValidationInitial()) {
    /// Register event handler
    /// When PhoneNumberChanged event is received, call _onPhoneNumberChanged
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
  }

  /// Handle PhoneNumberChanged event
  /// This is called every time the user types in the field
  Future<void> _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<PhoneValidationState> emit,
  ) async {
    // Check if the field is empty
    if (event.phone.isEmpty) {
      // If empty, return to initial state (no indicator)
      emit(const PhoneValidationInitial());
      return;
    }

    try {
      // Call the validation usecase
      // This goes through: usecase → repository → datasource → back
      final phoneNumber = await _validatePhoneNumber(event.phone);

      // Emit the result
      // UI now shows valid or invalid indicator based on phoneNumber.isValid
      emit(PhoneValidationResult(phoneNumber));
    } catch (e) {
      // If validation fails, we can emit an error
      // But for phone validation, we probably won't reach here
      // because the regex validation is synchronous and doesn't throw
      // Still good practice to handle it
      emit(const PhoneValidationInitial());
    }
  }
}
