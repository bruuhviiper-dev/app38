import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';
import 'landscape_image.dart';

/// Card imersivo de "Mais inspirações": a FOTO ocupa o card inteiro (largura
/// total), com gradiente para legibilidade, a frase em serifa e as ações
/// (categoria, favoritar, compartilhar) sobrepostas — mesmo estilo do card hero.
class InspirationCard extends StatelessWidget {
  const InspirationCard({
    super.key,
    required this.verse,
    required this.thumb,
    required this.isFavorite,
    required this.onShare,
    required this.onToggleFavorite,
    this.onEdit,
    this.onTap,
  });

  final Verse verse;
  final String thumb;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final cat = VerseData.categoryById(verse.categoryId);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Material(
        color: AppColors.surfaceHigh,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 208),
            child: Stack(
              children: [
                // Foto ocupa o card inteiro (decodificada em ~440px p/ leveza).
                Positioned.fill(
                    child: LandscapeImage(asset: thumb, thumb: 440)),
                const Positioned.fill(child: _InspScrim()),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _CatPill(
                              icon: cat.icon,
                              label: t.catName(verse.categoryId)),
                          const Spacer(),
                          _GlassAction(
                            icon: LucideIcons.heart,
                            active: isFavorite,
                            tooltip: t.save,
                            onTap: onToggleFavorite,
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text('“',
                          style: AppTextStyles.heroQuote.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 40,
                              height: 0.7)),
                      Text(
                        verse.text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inspQuote
                            .copyWith(color: Colors.white, height: 1.3),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      Row(
                        children: [
                          Container(width: 22, height: 2, color: AppColors.gold),
                          const Spacer(),
                          if (onEdit != null) ...[
                            _GlassAction(
                              icon: LucideIcons.wand,
                              tooltip: t.editImage,
                              onTap: onEdit!,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _GlassAction(
                            icon: LucideIcons.share2,
                            tooltip: t.share,
                            onTap: onShare,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selo de categoria translúcido (vidro) sobre a foto.
class _CatPill extends StatelessWidget {
  const _CatPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.overline.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Botão de ação "vidro" (favoritar/compartilhar) sobre a foto.
class _GlassAction extends StatelessWidget {
  const _GlassAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.32),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(icon,
                  size: 19, color: active ? AppColors.gold : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradiente escuro sobre a foto para garantir legibilidade do texto.
class _InspScrim extends StatelessWidget {
  const _InspScrim();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x22000000), Color(0x66000000), Color(0xDD06111F)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}
