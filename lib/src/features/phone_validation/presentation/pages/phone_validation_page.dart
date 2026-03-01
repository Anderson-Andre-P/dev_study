import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_theme_colors.dart';
import '../bloc/phone_validation_bloc.dart';
import '../bloc/phone_validation_event.dart';
import '../bloc/phone_validation_state.dart';

/// US Phone Number Input Formatter
///
/// Automatically formats phone input as (XXX) XXX-XXXX
/// - Only accepts digits (0-9)
/// - Limits to 10 digits
/// - Applies formatting automatically as user types
/// - Works with both manual typing and paste operations
///
/// Example:
/// User types: 5 5 5 1 2 3 4 5 6 7
/// Display becomes: (555) 123-4567
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

    // Format the number as (XXX) XXX-XXXX
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3) {
        formatted += ') ';
      } else if (i == 6) {
        formatted += '-';
      } else if (i == 0) {
        formatted += '(';
      }
      formatted += digitsOnly[i];
    }

    // Return the formatted value
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// PhoneValidationPage: The UI for real-time US phone number validation
///
/// This demonstrates:
/// 1. TextEditingController for managing input
/// 2. TextInputFormatter for automatic formatting (input mask)
/// 3. Reactive UI: listen to BLoC state and update display
/// 4. Real-time validation: dispatch event on every keystroke
/// 5. Visual feedback: show valid/invalid indicator
///
/// Notice: This page doesn't do any validation logic
/// It just displays the UI and sends events to the BLoC
/// The BLoC handles all the logic
class PhoneValidationPage extends StatefulWidget {
  const PhoneValidationPage({super.key});

  @override
  State<PhoneValidationPage> createState() => _PhoneValidationPageState();
}

class _PhoneValidationPageState extends State<PhoneValidationPage> {
  /// Controller to manage the text field
  /// We use StatefulWidget to manage the controller lifecycle
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    /// Clean up: dispose of the controller when the widget is removed
    /// This prevents memory leaks
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Validation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Title
            const Text(
              'Enter US Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Phone number input field
            /// Features:
            /// 1. Only accepts digits (0-9)
            /// 2. Automatic formatting: (XXX) XXX-XXXX
            /// 3. Limited to 10 digits
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                /// Limit to 10 digits before formatting
                FilteringTextInputFormatter.digitsOnly,
                /// Apply the (XXX) XXX-XXXX format
                USPhoneInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '(555) 123-4567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              /// On every keystroke, dispatch PhoneNumberChanged event
              /// The formatter has already applied the mask
              onChanged: (value) {
                context.read<PhoneValidationBloc>().add(
                  PhoneNumberChanged(value),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            /// Validation result indicator
            /// Uses BlocBuilder to listen to state changes
            BlocBuilder<PhoneValidationBloc, PhoneValidationState>(
              builder: (context, state) {
                // Check what state we're in and show appropriate UI
                if (state is PhoneValidationInitial) {
                  // Field is empty or cleared: show nothing
                  return const SizedBox.shrink();
                } else if (state is PhoneValidationResult) {
                  // We have a validation result
                  if (state.phoneNumber.isValid) {
                    // Valid phone number: show green indicator
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppThemeColors.success.withAlpha(25),
                        border: Border.all(
                          color: AppThemeColors.success,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppThemeColors.success,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Text(
                            'Valid US phone number',
                            style: TextStyle(
                              color: AppThemeColors.success,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Invalid phone number: show red indicator
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppThemeColors.error.withAlpha(25),
                        border: Border.all(
                          color: AppThemeColors.error,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: AppThemeColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Text(
                            'Invalid US phone number',
                            style: TextStyle(
                              color: AppThemeColors.error,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }

                // Fallback (shouldn't reach here)
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            /// Explanation text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'This demonstrates real-time validation with input formatting:\n\n'
                '1. Type only numbers (0-9)\n'
                '2. Auto-formatting applies: (XXX) XXX-XXXX\n'
                '3. Limited to 10 digits\n'
                '4. Valid indicator appears when complete\n\n'
                'Valid examples:\n'
                '• (555) 123-4567\n'
                '• (212) 555-2000\n'
                '• (410) 555-1234\n\n'
                'The formatter automatically adds parentheses\n'
                'and dashes as you type!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
