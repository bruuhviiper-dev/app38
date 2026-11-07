import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';
import 'landscape_image.dart';

/// Card compacto de "Mais inspirações": miniatura + frase + categoria +
/// ações de favoritar e compartilhar. Toca para abrir o detalhe. Theme-aware.
class InspirationCard extends StatelessWidget {
  const InspirationCard({
    super.key,
    required this.verse,
    required this.thumb,
    required this.isFavorite,
    required this.onShare,
    required this.onToggleFavorite,
    this.onTap,
  });

  final Verse verse;
  final String thumb;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
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
          padding: const EdgeInsets.all(AppSpacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.chip),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: LandscapeImage(asset: thumb, thumb: 72),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(verse.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inspQuote
                            .copyWith(color: p.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(VerseData.categoryById(verse.categoryId).icon,
                            size: 13, color: AppColors.gold),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(t.catName(verse.categoryId),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniAction(
                    icon: LucideIcons.heart,
                    color: isFavorite ? AppColors.gold : p.textSecondary,
                    tooltip: t.save,
                    onTap: onToggleFavorite,
                  ),
                  const SizedBox(height: 4),
                  _MiniAction(
                    icon: LucideIcons.share2,
                    color: p.textSecondary,
                    tooltip: t.share,
                    onTap: onShare,
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

class _MiniAction extends StatelessWidget {
  const _MiniAction({
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
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 19, color: color),
          ),
        ),
      ),
    );
  }
}
