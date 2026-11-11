import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';

/// Card de frase em listas (Favoritos, Pesquisa, Categoria): categoria (ícone
/// dourado + nome) + frase + ações EDITAR e favoritar. Theme-aware.
class VerseListCard extends StatelessWidget {
  const VerseListCard({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onEdit,
    this.onTap,
  });

  final Verse verse;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onEdit;
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
              Column(
                children: [
                  if (onEdit != null)
                    _CardAction(
                      icon: LucideIcons.wand,
                      color: AppColors.gold,
                      tooltip: t.editImage,
                      onTap: onEdit!,
                    ),
                  _CardAction(
                    icon: LucideIcons.heart,
                    color: isFavorite ? AppColors.gold : p.textSecondary,
                    tooltip: t.favorite,
                    onTap: onToggleFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão de ação do card (editar / favoritar), com tooltip traduzido e área de
/// toque confortável.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
