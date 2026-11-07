import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Foto de paisagem (asset) com FALLBACK elegante quando a imagem não existir:
/// um gradiente navy + ícone discreto. Usada no hero, nas categorias e nas
/// miniaturas de "Mais inspirações".
///
/// Carregamento EFICIENTE: quando [thumb] é passado (ex.: miniaturas do
/// seletor), a imagem é DECODIFICADA nesse tamanho (cacheWidth) — não guarda a
/// foto cheia em memória, o que mantém a rolagem fluida e leve em aparelhos
/// fracos.
class LandscapeImage extends StatelessWidget {
  const LandscapeImage(
      {super.key, required this.asset, this.fit = BoxFit.cover, this.thumb});
  final String asset;
  final BoxFit fit;

  /// Largura-alvo em px p/ decodificar miniaturas (ex.: ~140). Null = cheia.
  final int? thumb;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final cacheW = thumb == null ? null : (thumb! * dpr).round();
    return Image.asset(
      asset,
      fit: fit,
      gaplessPlayback: true,
      cacheWidth: cacheW,
      filterQuality: thumb == null ? FilterQuality.medium : FilterQuality.low,
      errorBuilder: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceHigh, AppColors.bg2],
          ),
        ),
        child: Center(
          child: Icon(LucideIcons.image, color: AppColors.textSecondary, size: 28),
        ),
      ),
    );
  }
}
