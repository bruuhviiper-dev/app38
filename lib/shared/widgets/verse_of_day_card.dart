import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/landscapes.dart';
import '../../data/verses.dart';
import '../../l10n/strings.dart';
import 'landscape_image.dart';

/// Card HERO da Frase do Dia: foto de paisagem + gradiente + selo "FRASE DO
/// DIA" + aspas + a frase + atribuição + botões Compartilhar / Salvar.
/// A altura se adapta ao texto (sem altura rígida) — seguro para 64 idiomas.
class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({
    super.key,
    required this.verse,
    required this.isFavorite,
    required this.onShare,
    required this.onToggleFavorite,
  });

  final Verse verse;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.hero),
      child: Stack(
        children: [
          Positioned.fill(child: LandscapeImage(asset: Landscapes.hero)),
          const Positioned.fill(child: _Scrim()),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _DayBadge(label: t.verseOfDay),
                    const Spacer(),
                    const Icon(LucideIcons.sun,
                        color: AppColors.gold, size: 22),
                  ],
                ),
                // Faixa da foto respirando antes da frase (constante pequena,
                // não é altura total rígida).
                const SizedBox(height: 56),
                Text('“',
                    style: AppTextStyles.heroQuote.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 52,
                        height: 0.8)),
                const SizedBox(height: 2),
                Text(
                  verse.text,
                  style: AppTextStyles.heroQuote
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.x3),
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 2,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text('— ${t.dailyInspiration}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: AppSpacing.x5),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onShare,
                        icon: const Icon(LucideIcons.share2, size: 18),
                        label: Text(t.share),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          LucideIcons.heart,
                          size: 18,
                          color: isFavorite
                              ? AppColors.gold
                              : AppColors.textPrimary,
                        ),
                        label: Text(t.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.goldPill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.star, size: 13, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.overline.copyWith(color: AppColors.gold)),
        ],
      ),
    );
  }
}

/// Gradiente escuro sobre a foto para garantir legibilidade do texto.
class _Scrim extends StatelessWidget {
  const _Scrim();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x22000000), Color(0x55000000), Color(0xCC06111F)],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
    );
  }
}
