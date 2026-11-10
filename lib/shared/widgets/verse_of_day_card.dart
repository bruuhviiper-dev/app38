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
    required this.onNewVerse,
  });

  final Verse verse;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback onNewVerse;

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
                    Semantics(
                      button: true,
                      label: t.newVerse,
                      child: Tooltip(
                        message: t.newVerse,
                        child: InkWell(
                          onTap: onNewVerse,
                          borderRadius: BorderRadius.circular(22),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(LucideIcons.refreshCw,
                                color: AppColors.gold, size: 20),
                          ),
                        ),
                      ),
                    ),
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
                _HeroActions(
                  share: t.share,
                  save: t.save,
                  isFavorite: isFavorite,
                  onShare: onShare,
                  onToggleFavorite: onToggleFavorite,
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
        // Fundo escuro opaco (não translúcido) p/ o selo NUNCA "sumir" sobre
        // fotos claras (céu/neve).
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
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

/// Ações do card (Compartilhar / Salvar). Lado a lado no tamanho normal; com
/// fonte grande, EMPILHA em largura total (sem encolher a fonte) para "Compartilhar"
/// nunca quebrar no meio. Área de toque mín. 50dp (tema). Rótulos em 1 linha.
class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.share,
    required this.save,
    required this.isFavorite,
    required this.onShare,
    required this.onToggleFavorite,
  });

  final String share;
  final String save;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final stacked = scale >= 1.2;

    final shareBtn = FilledButton.icon(
      onPressed: onShare,
      icon: const Icon(LucideIcons.share2, size: 18),
      label: Text(share, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    final saveBtn = OutlinedButton.icon(
      onPressed: onToggleFavorite,
      icon: Icon(LucideIcons.heart,
          size: 18,
          color: isFavorite ? AppColors.gold : AppColors.textPrimary),
      label: Text(save, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    if (stacked) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: shareBtn),
          const SizedBox(height: AppSpacing.x3),
          SizedBox(width: double.infinity, child: saveBtn),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: shareBtn),
        const SizedBox(width: AppSpacing.x3),
        Expanded(child: saveBtn),
      ],
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
