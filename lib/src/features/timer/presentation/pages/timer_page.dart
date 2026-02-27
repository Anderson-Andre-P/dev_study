import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/theme/app_spacing.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart' as events;
import '../bloc/timer_state.dart' as states;

/// TimerPage: Countdown timer UI
///
/// This demonstrates:
/// 1. User input (duration selection)
/// 2. Reactive state changes (BlocBuilder)
/// 3. Stream management (timer ticks)
/// 4. State transitions (idle → running → finished)
/// 5. Error handling
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  /// Text controller for duration input
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: BlocBuilder<TimerBloc, states.TimerState>(
            builder: (context, state) {
              // Show different UI based on state
              if (state is states.TimerInitial || state is states.TimerInputState) {
                // Initial state or ready for new timer
                return _buildInputForm(context);
              } else if (state is states.TimerRunning) {
                // Timer is counting down
                return _buildRunningTimer(context, state);
              } else if (state is states.TimerPaused) {
                // Timer is paused
                return _buildPausedTimer(context, state);
              } else if (state is states.TimerFinished) {
                // Timer reached 0
                return _buildFinishedTimer(context, state);
              } else if (state is states.TimerError) {
                // Error occurred
                return _buildErrorScreen(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// Input form: User enters duration
  Widget _buildInputForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Set Timer',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Enter duration in seconds',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g., 60',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixText: 'seconds',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Timer'),
          onPressed: () {
            final duration = int.tryParse(_durationController.text);
            if (duration != null && duration > 0) {
              context.read<TimerBloc>().add(events.TimerStarted(duration));
              _durationController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid duration')),
              );
            }
          },
        ),
      ],
    );
  }

  /// Running state: Countdown display with pause button
  Widget _buildRunningTimer(BuildContext context, states.TimerRunning state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_bottom, size: 64, color: Colors.orange),
        const SizedBox(height: AppSpacing.lg),
        // Large countdown display
        Text(
          state.timerValue.formattedTime,
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Progress bar
        LinearProgressIndicator(
          value: state.timerValue.progress,
          minHeight: 8,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              onPressed: () {
                context.read<TimerBloc>().add(const events.TimerPaused());
              },
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              onPressed: () {
                context.read<TimerBloc>().add(const events.TimerStopped());
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Paused state: Show remaining time with resume option
  Widget _buildPausedTimer(BuildContext context, states.TimerPaused state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pause_circle_outline, size: 64, color: Colors.yellow),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Paused',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          state.timerValue.formattedTime,
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              onPressed: () {
                context.read<TimerBloc>().add(const events.TimerResumed());
              },
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              onPressed: () {
                context.read<TimerBloc>().add(const events.TimerStopped());
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Finished state: Show completion message
  Widget _buildFinishedTimer(BuildContext context, states.TimerFinished state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Time\'s Up!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          state.timerValue.formattedTime,
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Countdown complete!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Start New Timer'),
          onPressed: () {
            // Reset to input state by stopping the timer
            // This will show the input form again
            context.read<TimerBloc>().add(const events.TimerStopped());
          },
        ),
      ],
    );
  }

  /// Error state: Show error message
  Widget _buildErrorScreen(BuildContext context, states.TimerError state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: AppSpacing.lg),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: () {
            // Go back to input state by stopping the timer
            // Clear the state and start fresh
            context.read<TimerBloc>().add(const events.TimerStopped());
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
