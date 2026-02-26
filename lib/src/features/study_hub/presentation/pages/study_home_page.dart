import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../bloc/study_bloc.dart';
import '../bloc/study_event.dart';
import '../bloc/study_state.dart';
import '../widgets/study_card.dart';

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<StudyBloc>().add(const StudyLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Study Hub')),
      body: BlocBuilder<StudyBloc, StudyState>(
        builder: (context, state) {
          if (state is StudyLoading || state is StudyInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: AppSpacing.md),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudyBloc>().add(const StudyLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is StudyLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) => StudyCard(item: state.items[index]),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class StudyItemView {
  final String title;
  final String description;
  final IconData icon;

  final WidgetBuilder pageBuilder;

  const StudyItemView({
    required this.title,
    required this.description,
    required this.icon,

    required this.pageBuilder,
  });
}
