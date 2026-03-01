# Phone Validation: Real-Time Input Validation with Input Formatting

## Overview

The **Phone Validation** feature demonstrates real-time user input validation combined with automatic input formatting using BLoC state management. Unlike the Counter (discrete button clicks) or Weather (single API request), this feature validates input on **every keystroke**, showing immediate visual feedback.

This guide explains how to implement responsive, real-time validation with automatic input masking while maintaining clean architecture.

---

## What is Phone Validation?

A feature that:
- Takes US phone number input from a text field
- Only accepts digits (0-9)
- Automatically formats input as: **(XXX) XXX-XXXX**
- Validates on every keystroke (in real-time)
- Shows a green indicator when 10 digits are entered (valid)
- Shows a red indicator when less than 10 digits (invalid)
- Clears the indicator when the field is empty

**Valid examples:**
- User types: `5551234567` → displays as `(555) 123-4567` ✅
- User types: `2125552000` → displays as `(212) 555-2000` ✅
- User types: `4105551234` → displays as `(410) 555-1234` ✅

**Invalid examples:**
- `123` (too short)
- `abc` (letters not allowed - formatter removes them)
- Empty field (no validation shown)

---

## The 4-Layer Architecture

### Layer 1: Domain (Business Logic)

**Files:**
- `entities/phone_number.dart` - What a phone number is
- `repositories/phone_validation_repository.dart` - What validation operations we can do
- `usecases/validate_phone_number.dart` - How to validate

**Key Difference from Counter:**
- This feature validates strings instead of modifying numbers
- But the same architecture pattern applies

**What it does:**
```
PhoneNumber entity (holds value + validation result)
    ↑
PhoneValidationRepository interface (defines validation)
    ↑
ValidatePhoneNumber usecase (implements validation business logic)
```

### Layer 2: Data (How Validation Works)

**Files:**
- `datasources/phone_validation_datasource.dart` - Where validation happens
- `repositories/phone_validation_repository_impl.dart` - Transforms raw validation result to entity

**Key Point:** Validation happens here
- This example: validates US phone numbers (exactly 10 digits)
- In real apps: could use API validation, database lookup, carrier validation

**What it does:**
```
Raw phone string ("(555) 123-4567")
    ↓
DataSource: extract digits, check if exactly 10 digits
    ↓
Returns bool (true if 10 digits, false otherwise)
    ↓
Repository: wrap bool in PhoneNumber entity
    ↓
Returns PhoneNumber(value: "(555) 123-4567", isValid: true)
```

### Layer 3: Presentation - BLoC (State Management)

**Files:**
- `bloc/phone_validation_event.dart` - User actions (typing in field)
- `bloc/phone_validation_state.dart` - Validation results (valid/invalid/empty)
- `bloc/phone_validation_bloc.dart` - The orchestrator

**Key Difference from Counter:**
- Counter receives discrete events (button taps)
- Phone Validation receives continuous events (every keystroke)
- But the same state management pattern applies

**What it does:**
```
User types in text field (every keystroke)
    ↓
UI sends PhoneNumberChanged event to BLoC
    ↓
BLoC receives event
    ↓
BLoC checks if field is empty
    ↓
If empty → emit PhoneValidationInitial
If not empty → call ValidatePhoneNumber usecase
    ↓
Usecase validates
    ↓
BLoC emits PhoneValidationResult state
    ↓
UI listens to state
    ↓
UI rebuilds with valid/invalid indicator
```

### Layer 4: Presentation - UI

**Files:**
- `pages/phone_validation_page.dart` - The screen

**Key Components:**
- `TextEditingController` - Manages text field
- `TextField` with `onChanged` callback - Sends event on every keystroke
- `BlocBuilder` - Listens to validation state
- Visual indicators (green/red containers with icons)

**What it does:**
```
User types in field
    ↓
onChanged callback fires
    ↓
Send event: context.read<PhoneValidationBloc>().add(PhoneNumberChanged(value))
    ↓
BLocBuilder listens for state changes
    ↓
State changes → UI shows valid/invalid indicator
```

---

## Data Flow: Complete Example

### User Types "5" in the Field

```
Step 1: User types "5"
   ↓
Step 2: USPhoneInputFormatter.formatEditUpdate is called
   → Extracts digits: "5"
   → Formats: "(5" (adds opening parenthesis)
   ↓
Step 3: TextField's onChanged callback fires with "(5"
   ↓
Step 4: UI sends event to BLoC
   context.read<PhoneValidationBloc>().add(PhoneNumberChanged("(5"));
   ↓
Step 5: BLoC's _onPhoneNumberChanged handler is called
   ↓
Step 6: BLoC checks if phone is empty
   → "(5" is not empty, so continue
   ↓
Step 7: BLoC calls ValidatePhoneNumber usecase
   ↓
Step 8: Usecase calls repository.validate("(5")
   ↓
Step 9: Repository calls datasource.validate("(5")
   ↓
Step 10: Datasource extracts digits: "5"
   → Only 1 digit, needs 10, so isValid = false
   ↓
Step 11: Datasource returns false
   ↓
Step 12: Repository wraps in PhoneNumber(value: "(5", isValid: false)
   ↓
Step 13: Repository returns PhoneNumber to usecase
   ↓
Step 14: Usecase returns PhoneNumber to BLoC
   ↓
Step 15: BLoC emits PhoneValidationResult state
   ↓
Step 16: BlocBuilder detects state change
   ↓
Step 17: Builder checks state.phoneNumber.isValid
   → isValid = false, so show red "Invalid" container
   ↓
Step 18: UI shows red indicator below the field
```

### User Continues Typing: "5551234567"

```
Step 1: User types more digits: 5, 5, 5, 1, 2, 3, 4, 5, 6, 7
   ↓
Step 2: USPhoneInputFormatter.formatEditUpdate is called on EACH keystroke
   → After 3rd digit: "5" "5" "5" → "(555)"
   → After 6th digit: "5" "5" "5" "1" "2" "3" → "(555) 123"
   → After 10th digit: "5" "5" "5" "1" "2" "3" "4" "5" "6" "7" → "(555) 123-4567"
   ↓
Step 3: Same validation process as above happens on each keystroke
   ↓
Step 9: Datasource extracts all 10 digits from "(555) 123-4567"
   → Exactly 10 digits! isValid = true
   ↓
...same steps 10-18...
   ↓
Step 18: UI now shows GREEN "Valid US phone number" indicator
```

### User Tries to Type Extra Digits

```
Step 1: Field already has 10 digits: "(555) 123-4567"
   ↓
Step 2: User types another digit "8"
   ↓
Step 3: USPhoneInputFormatter.formatEditUpdate is called
   → Extracts digits: "55512345678" (11 digits!)
   → But we only allow 10 max
   → Return oldValue (reject the change)
   ↓
Step 4: TextField keeps showing "(555) 123-4567"
   ↓
Step 5: The extra digit is silently dropped (no visual feedback)
```

**Key Insight:** The formatter prevents invalid input at the source, so the validator always receives properly formatted data.

### User Clears the Field

```
Step 1: User deletes all text → field is now ""
   ↓
Step 2-3: Formatter gets empty string, outputs empty string
   ↓
Step 4: Event sent to BLoC with ""
   ↓
Step 5: BLoC's _onPhoneNumberChanged handler is called
   ↓
Step 6: BLoC checks if phone is empty
   → "" is empty, so emit PhoneValidationInitial (not PhoneValidationResult)
   ↓
Step 7: BlocBuilder detects state change
   ↓
Step 8: Builder checks state type
   → PhoneValidationInitial, so show nothing (SizedBox.shrink())
   ↓
Step 9: UI indicator disappears
```

**Key Insight:** Clearing the field goes back to the initial state (no indicator), not to an "invalid" state. This provides better UX.

---

## Key Concepts Explained

### 1. **PhoneNumberChanged Event = Every Keystroke**

```dart
class PhoneNumberChanged extends PhoneValidationEvent {
  final String phone;
  const PhoneNumberChanged(this.phone);
}
```

**What it means:**
- Every time the user types/deletes a character, we create a new event
- The event contains the current text in the field
- We send it to the BLoC

**Real-world analogy:**
- You're writing a text message
- After each character, the spell-checker runs
- It shows you a red underline if misspelled
- Phone validation works the same way

### 2. **Two States: Initial vs Result**

```dart
class PhoneValidationInitial extends PhoneValidationState {
  const PhoneValidationInitial();
}

class PhoneValidationResult extends PhoneValidationState {
  final PhoneNumber phoneNumber;
  const PhoneValidationResult(this.phoneNumber);
}
```

**What it means:**
- `PhoneValidationInitial`: Field is empty, show no indicator
- `PhoneValidationResult`: Field has text, show valid or invalid indicator

**Why two states?**

Good UX Design:
```
User opens the app
    ↓
Field is empty → Show PhoneValidationInitial
    → No red "invalid" message (that would be confusing)
    ↓
User starts typing "1"
    ↓
Invalid number (too short) → Show red "Invalid" indicator
    ↓
User continues typing "+5511999999999"
    ↓
Valid number → Show green "Valid" indicator
```

### 3. **Real-Time Validation in BLoC**

```dart
Future<void> _onPhoneNumberChanged(
  PhoneNumberChanged event,
  Emitter<PhoneValidationState> emit,
) async {
  if (event.phone.isEmpty) {
    emit(const PhoneValidationInitial());
    return;
  }

  try {
    final phoneNumber = await _validatePhoneNumber(event.phone);
    emit(PhoneValidationResult(phoneNumber));
  } catch (e) {
    emit(const PhoneValidationInitial());
  }
}
```

**What it means:**
1. **Check if empty:** If so, show initial state
2. **Call usecase:** Validate the phone number
3. **Emit result:** Show the validation result
4. **Handle error:** Fallback to initial state if something goes wrong

### 4. **Input Formatting with TextInputFormatter**

```dart
class USPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only keep digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      return oldValue;
    }

    // Format as (XXX) XXX-XXXX
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3) formatted += ') ';
      if (i == 6) formatted += '-';
      if (i == 0) formatted += '(';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

**What it means:**
- `formatEditUpdate` is called on EVERY keystroke (before onChanged)
- Extract digits only: `"(555) 123-4567"` → `"5551234567"`
- Limit to 10 digits (reject anything longer)
- Format back as: `"(555) 123-4567"`
- Return the formatted value and cursor position

**User Experience:**
```
User types:  5      5      5      1      2      3      4      5      6      7
Display:    (5    (55   (555  (555) (555) 1  (555) 12 (555) 123 (555) 123-4567
```

**Key Benefits:**
- User only types numbers, formatter adds parentheses and dashes
- Automatic formatting (input mask) improves UX
- Input is always in the correct format for validation
- Rejecting extra digits at the formatter level prevents invalid input

### 5. **StatefulWidget for TextEditingController**

```dart
class PhoneValidationPage extends StatefulWidget {
  const PhoneValidationPage({super.key});

  @override
  State<PhoneValidationPage> createState() => _PhoneValidationPageState();
}

class _PhoneValidationPageState extends State<PhoneValidationPage> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
```

**Why StatefulWidget?**
- Need to manage the `TextEditingController` lifecycle
- Must dispose of it when widget is removed (prevents memory leaks)

**Flow:**
1. `initState`: Create the controller
2. `build`: Use the controller in the TextField
3. `dispose`: Clean up when done

---

## Comparison: Counter vs Phone Validation

| Aspect | Counter | Phone Validation |
|--------|---------|------------------|
| **Event frequency** | Discrete (button taps) | Continuous (every keystroke) |
| **Input handling** | None (buttons only) | Text input with formatting |
| **Operation** | Increment/Decrement/Reset | Format + Validate |
| **State complexity** | Loading, Updated, Error | Initial, Result |
| **UI feedback** | Display number | Show valid/invalid indicator |
| **Input formatter** | None | USPhoneInputFormatter |
| **Data layer** | Simple increment logic | Digit extraction + validation |

**Key Learning:**
Both use the same BLoC pattern, but Phone Validation shows:
1. **Real-time, high-frequency events** (every keystroke)
2. **Input formatting** (automatic input mask)
3. **Filtering user input** (only digits allowed)
4. **Data transformation** before validation

---

## Why This Pattern Matters

### 1. **Separation of Concerns**

Validation logic (datasource) is separate from:
- UI code (page)
- State management (BLoC)
- Business rules (usecase)

### 2. **Easy to Change Validation Rules**

Change validation without touching UI:
```dart
// Old: regex validation
final pattern = RegExp(r'^...$');

// New: API validation
final response = await http.get('api.com/validate?phone=$phone');
final isValid = response.statusCode == 200;

// BLoC and UI don't change!
```

### 3. **Testable**

Test validation without building UI:
```dart
test('validate phone number', () async {
  final bloc = PhoneValidationBloc(ValidatePhoneNumber(repository));

  bloc.add(PhoneNumberChanged('+5511999999999'));

  expect(
    bloc.stream,
    emits(PhoneValidationResult(
      PhoneNumber(value: '+5511999999999', isValid: true),
    )),
  );
});
```

### 4. **Reusable**

Domain layer can be used in backend, CLI, web:
```dart
// Mobile app
final result = await ValidatePhoneNumber(repository).call('+5511999999999');

// Backend
final result = await ValidatePhoneNumber(repository).call('+5511999999999');

// Web
const result = await ValidatePhoneNumber(repository).call('+5511999999999');
```

---

## Real-Time Validation Patterns

### Pattern 1: Validate On Change (This Example)

```dart
TextField(
  onChanged: (value) {
    context.read<PhoneValidationBloc>().add(PhoneNumberChanged(value));
  },
)
```

**Pros:** Immediate feedback
**Cons:** Validates on every keystroke (might be expensive for API validation)

### Pattern 2: Debounced Validation

```dart
// Wait 500ms after user stops typing before validating
StreamTransformer<PhoneNumberChanged, PhoneNumberChanged> debounceTransformer() {
  return StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      sink.add(data);
    }
  );
}
```

**Pros:** Reduces API calls
**Cons:** Delayed feedback

### Pattern 3: Validate On Submit

```dart
TextField(
  onSubmitted: (value) {
    context.read<PhoneValidationBloc>().add(PhoneNumberChanged(value));
  },
)
```

**Pros:** Validates only when user is done
**Cons:** Less immediate feedback

---

## Code Walkthrough

### 1. User Typing in the TextField with Automatic Formatting

**File**: `phone_validation_page.dart`

```dart
TextField(
  controller: _phoneController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,  // Only allow 0-9
    USPhoneInputFormatter(),                  // Apply (XXX) XXX-XXXX format
  ],
  onChanged: (value) {
    context.read<PhoneValidationBloc>().add(
      PhoneNumberChanged(value),
    );
  },
)
```

**What it means:**
1. `keyboardType: TextInputType.number` - Show numeric keyboard
2. `FilteringTextInputFormatter.digitsOnly` - Only allow digits 0-9
3. `USPhoneInputFormatter()` - Apply the (XXX) XXX-XXXX format
4. `onChanged` - Send the formatted value to BLoC on every keystroke

### 2. Input Formatter: Automatic Masking

**File**: `phone_validation_page.dart`

```dart
class USPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 10) {
      return oldValue;  // Reject if more than 10 digits
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3) formatted += ') ';
      if (i == 6) formatted += '-';
      if (i == 0) formatted += '(';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

**What it means:**
- Called on EVERY keystroke (before onChanged)
- Extracts digits only
- Applies formatting: (XXX) XXX-XXXX
- Limits to 10 digits maximum
- Returns formatted value with cursor at end

### 3. BLoC Receiving the Event

**File**: `phone_validation_bloc.dart`

```dart
Future<void> _onPhoneNumberChanged(
  PhoneNumberChanged event,
  Emitter<PhoneValidationState> emit,
) async {
  if (event.phone.isEmpty) {
    emit(const PhoneValidationInitial());
    return;
  }

  final phoneNumber = await _validatePhoneNumber(event.phone);
  emit(PhoneValidationResult(phoneNumber));
}
```

**What it means:**
1. Check if empty → show initial state (no indicator)
2. Otherwise → call validation usecase
3. Emit result with validation outcome

### 4. Validation: Check for Exactly 10 Digits

**File**: `phone_validation_datasource.dart`

```dart
Future<bool> validate(String phone) async {
  // Remove formatting: "(555) 123-4567" → "5551234567"
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
```

**What it means:**
- Extract all digits from the formatted string
- Check if exactly 10 digits
- Return true only if valid, false otherwise

### 5. Repository Wrapping in Entity

**File**: `phone_validation_repository_impl.dart`

```dart
@override
Future<PhoneNumber> validate(String phone) async {
  final isValid = await _dataSource.validate(phone);

  return PhoneNumber(
    value: phone,
    isValid: isValid,
  );
}
```

**What it means:**
- Get raw validation result (bool)
- Wrap in `PhoneNumber` entity with both value and validity
- Return to BLoC

### 6. UI Showing the Result

**File**: `phone_validation_page.dart`

```dart
BlocBuilder<PhoneValidationBloc, PhoneValidationState>(
  builder: (context, state) {
    if (state is PhoneValidationInitial) {
      return const SizedBox.shrink(); // Show nothing
    } else if (state is PhoneValidationResult) {
      if (state.phoneNumber.isValid) {
        return Container(
          color: Colors.green,
          child: Text('Valid US phone number'),  // 10 digits ✅
        );
      } else {
        return Container(
          color: Colors.red,
          child: Text('Invalid US phone number'),  // < 10 digits ❌
        );
      }
    }
  }
)
```

**What it means:**
1. Listen to state changes
2. If initial → show nothing
3. If result with valid (10 digits) → show green indicator
4. If result with invalid (< 10 digits) → show red indicator

---

## Learning Checklist

- [ ] Understand the PhoneNumber entity
- [ ] Understand what PhoneValidationRepository does
- [ ] Understand what ValidatePhoneNumber usecase does
- [ ] Understand regex pattern for phone validation
- [ ] Understand PhoneNumberChanged event
- [ ] Understand PhoneValidationInitial state
- [ ] Understand PhoneValidationResult state
- [ ] Understand how BLoC handles real-time events
- [ ] Understand why we have two states (Initial vs Result)
- [ ] Trace the complete data flow (keystroke → UI → BLoC → validation → state → UI update)
- [ ] Understand TextEditingController lifecycle
- [ ] Explain the pattern to someone else
- [ ] Modify it to use API validation instead of regex

---

## Try It Yourself

1. **Run the app** → Tap "Phone Validation" in Study Hub
2. **Notice the formatter** → Type only numbers, watch the formatting appear automatically
3. **Try valid US numbers (10 digits):**
   - Type `5551234567` → displays as `(555) 123-4567` ✅ (green indicator)
   - Type `2125552000` → displays as `(212) 555-2000` ✅ (green indicator)
   - Type `4105551234` → displays as `(410) 555-1234` ✅ (green indicator)
4. **Try invalid entries:**
   - Type `123` → `(123` ❌ (too short, red indicator)
   - Try `abc` → Gets filtered out (only digits allowed)
   - Type `55512345678` → Extra digit is rejected (max 10)
5. **Observe the input formatter:**
   - Notice parentheses appear automatically after 3 digits
   - Notice dash appears automatically after 6 digits
   - You only type numbers, formatter adds formatting
6. **Read the comments** → Understand each part
7. **Trace the flow:**
   - Follow a keystroke from TextField → Formatter → BLoC → Datasource → UI
   - Notice how the formatter prevents invalid input at the source
8. **Modify it:**
   - Add support for +1 prefix (US country code)
   - Change to support international format (+XX) XXX XXXX XXXX
   - Add a "Clear" button to easily reset the field
   - Add validation history showing attempted numbers
   - Integrate with a real phone carrier API (Twilio, etc.)

---

## Real-World Extensions

In a real app, you might:

### Input Validation Enhancements
- **Carrier Validation:** Use an API to check if the number is real (e.g., Twilio Lookup API)
- **Area Code Validation:** Only allow valid US area codes (200-999 range has restrictions)
- **NPA-NXX Validation:** Check if area code + exchange code combination is valid
- **Regex Enhancement:** Add support for +1 prefix (US country code)

### User Experience
- **E.164 Format:** Store as +15551234567 (international standard)
- **Different Formats:** Support (555) 123-4567, 555-123-4567, 5551234567
- **Country Code Detection:** Auto-detect country and apply appropriate formatter
- **Copy Button:** Easy copy-to-clipboard functionality
- **Paste Detection:** Handle pasted formatted numbers

### Business Logic
- **SMS Verification:** Send OTP to verify ownership
- **Save to Database:** Persist validated numbers with metadata
- **Duplicate Detection:** Check if number already registered
- **Phone Type Detection:** Detect if mobile, landline, or VoIP
- **Spam List Check:** Check against known spam databases

### Accessibility
- **Screen Reader Support:** Announce validation results ("Valid ten-digit US phone number")
- **Error Messages:** Clear explanations of why a number is invalid
- **Voice Input:** Support dictation and speech-to-text
- **High Contrast Mode:** Better visibility for vision-impaired users

All of these are easy to add because of the architecture! Just change the datasource or add validation steps without touching the BLoC or UI.

---

## Key Takeaway

**Real-time validation demonstrates how BLoC handles high-frequency events while maintaining clean architecture.**

The pattern is the same whether you're:
- Validating phone numbers (this example)
- Searching as you type
- Filtering a list
- Auto-saving a document

The architecture scales from a single button tap (Counter) to thousands of events per second.

---

Happy learning! 🎓
