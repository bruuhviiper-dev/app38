import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';
import 'landscape_image.dart';

/// Card de categoria: foto + gradiente + chip do ícone (dourado) + nome +
/// descrição curta. Altura controlada pela grade (mainAxisExtent).
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final VerseCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final name = t.catName(category.id);
    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LandscapeImage(asset: category.asset),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xCC06111F)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.goldPill,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Icon(category.icon, size: 16, color: AppColors.gold),
                  ),
                  const Spacer(),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.categoryName
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(t.catDesc(category.id),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.categoryDesc
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
