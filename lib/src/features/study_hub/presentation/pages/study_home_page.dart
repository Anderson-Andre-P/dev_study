import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../widgets/study_card.dart';
import 'layout_study_page.dart';

class StudyHomePage extends StatelessWidget {
  const StudyHomePage({super.key});

  static final List<StudyItemView> _items = [
    StudyItemView(
      title: 'Layouts',
      description: 'Experimentos com composição de UI',
      icon: Icons.grid_view_rounded,
      pageBuilder: (_) => const LayoutStudyPage(),
    ),
    StudyItemView(
      title: 'Animations',
      description: 'Testes de animações implícitas/explicitas',
      icon: Icons.animation_outlined,
      pageBuilder: (_) => const LayoutStudyPage(),
    ),
    StudyItemView(
      title: 'State Management',
      description: 'Comparações entre abordagens',
      icon: Icons.sync_alt_outlined,
      pageBuilder: (_) => const LayoutStudyPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Study Hub')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, index) => StudyCard(item: _items[index]),
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
