import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/theme/app_spacing.dart';
import '../bloc/counter_bloc.dart';
import '../bloc/counter_event.dart';
import '../bloc/counter_state.dart';

/// CounterPage: The UI for the counter feature
///
/// This is a complete example of a BLoC-based screen.
/// It demonstrates:
/// 1. How to read the BLoC from context
/// 2. How to send events to the BLoC
/// 3. How to listen to state changes with BlocBuilder
/// 4. How to update the UI reactively
///
/// Notice: This page doesn't do any business logic
/// It just displays the UI and sends events to the BLoC
/// The BLoC handles all the logic
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with BLoC'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Display the counter value
            /// This is where BlocBuilder comes in!
            /// BlocBuilder listens to CounterBloc state changes
            /// Whenever the BLoC emits a new state, this builder is called
            BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                // Check what state we're in and show appropriate UI
                if (state is CounterInitial) {
                  // Starting state: show 0
                  return const Text(
                    '0',
                    style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                  );
                } else if (state is CounterLoading) {
                  // Operation in progress: show spinner
                  return const SizedBox(
                    height: 72,
                    child: Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else if (state is CounterUpdated) {
                  // We have a value: display it
                  return Text(
                    '${state.value}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  );
                } else if (state is CounterError) {
                  // Error occurred: show error message
                  return Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  );
                }

                // Fallback (shouldn't reach here)
                return const Text('Unknown state');
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            /// Description of what this demonstrates
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'This counter demonstrates BLoC state management:\n\n'
                '1. Tap +/- buttons to send events\n'
                '2. BLoC processes events\n'
                '3. BLoC emits new states\n'
                '4. UI rebuilds reactively\n\n'
                'Read the comments in the code to understand the architecture!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// Button Row: Increment, Decrement, Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Decrement Button
                ElevatedButton(
                  /// When user taps this button:
                  /// 1. We get the BLoC from context.read()
                  /// 2. We add a CounterDecremented event
                  /// 3. The BLoC receives this event
                  /// 4. The BLoC's _onCounterDecremented handler is called
                  /// 5. Which calls the decrement usecase
                  /// 6. Which calls the repository
                  /// 7. Which calls the datasource
                  /// 8. The datasource decrements the value
                  /// 9. The value flows back up to the BLoC
                  /// 10. The BLoC emits a new CounterUpdated state
                  /// 11. The BlocBuilder detects the state change
                  /// 12. This builder is called again
                  /// 13. The UI shows the new value
                  onPressed: () {
                    context.read<CounterBloc>().add(
                      const CounterDecremented(),
                    );
                  },
                  child: const Text('-'),
                ),

                const SizedBox(width: AppSpacing.md),

                /// Increment Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  /// Same flow as decrement, but with CounterIncremented event
                  onPressed: () {
                    context.read<CounterBloc>().add(
                      const CounterIncremented(),
                    );
                  },
                ),

                const SizedBox(width: AppSpacing.md),

                /// Reset Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  /// Same flow, but with CounterReset event
                  onPressed: () {
                    context.read<CounterBloc>().add(
                      const CounterReset(),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            /// Key Learning Points
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Key Concept: Reactive UI\n\n'
                'You don\'t tell the UI "show 5"\n'
                'Instead, the BLoC emits state "value is 5"\n'
                'The UI automatically shows it\n\n'
                'If the BLoC emits "value is 6", the UI automatically updates\n'
                'No setState(), no manual updates\n'
                'Just: State changes → UI rebuilds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
