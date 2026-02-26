import 'package:flutter/material.dart';
import '../pages/study_home_page.dart';
import '../../../../core/presentation/theme/app_border_radius.dart';
import '../../../../core/presentation/theme/app_container_theme.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_theme_colors.dart';

class StudyCard extends StatelessWidget {
  final StudyItemView item;

  const StudyCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: AppBorderRadius.medium,
      onTap: () {},
      child: Ink(
        decoration: AppContainerTheme.card.copyWith(
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x14000000),
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 40, color: AppThemeColors.primary),

            const Spacer(),

            Text(
              item.title,
              style: textTheme.headlineMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              item.description,
              style: textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
