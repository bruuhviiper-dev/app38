import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Foto de paisagem (asset) com FALLBACK elegante quando a imagem não existir:
/// um gradiente navy + ícone discreto. Usada no hero, nas categorias e nas
/// miniaturas de "Mais inspirações".
class LandscapeImage extends StatelessWidget {
  const LandscapeImage({super.key, required this.asset, this.fit = BoxFit.cover});
  final String asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      gaplessPlayback: true,
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
