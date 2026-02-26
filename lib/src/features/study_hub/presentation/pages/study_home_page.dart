import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../widgets/study_card.dart';

class StudyHomePage extends StatelessWidget {
  const StudyHomePage({super.key});

  static const List<StudyItemView> _items = [
    StudyItemView(
      title: 'Layouts',
      description: 'Experimentos com composição de UI',
      icon: Icons.grid_view_rounded,
    ),
    StudyItemView(
      title: 'Animations',
      description: 'Testes de animações implícitas/explicitas',
      icon: Icons.animation_outlined,
    ),
    StudyItemView(
      title: 'State Management',
      description: 'Comparações entre abordagens',
      icon: Icons.sync_alt_outlined,
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

  const StudyItemView({
    required this.title,
    required this.description,
    required this.icon,
  });
}
