import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';

/// Card de frase em listas (Favoritos, Pesquisa, Categoria): categoria (ícone
/// dourado + nome) + frase + coração de favoritar. Theme-aware.
class VerseListCard extends StatelessWidget {
  const VerseListCard({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onTap,
  });

  final Verse verse;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final cat = VerseData.categoryById(verse.categoryId);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: p.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(cat.icon, size: 14, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(t.catName(verse.categoryId),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(verse.text,
                        style: AppTextStyles.inspQuote
                            .copyWith(color: p.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Semantics(
                button: true,
                label: t.favorite,
                child: InkWell(
                  onTap: onToggleFavorite,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(LucideIcons.heart,
                        size: 20,
                        color: isFavorite
                            ? AppColors.gold
                            : p.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
