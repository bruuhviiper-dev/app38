import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/strings.dart';

/// Logo da marca: chip "nascer do sol" dourado + nome do app. Usado no Splash
/// e no Onboarding. [stacked] empilha (vertical) ou alinha (horizontal).
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 72,
    this.stacked = true,
    this.onDark = true,
  });

  final double size;
  final bool stacked;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final name = T.of(context).appName;
    final titleColor = AppColors.gold;

    final sun = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gold, AppColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(LucideIcons.sunrise, color: AppColors.bg, size: size * 0.54),
    );

    final title = Text(
      name,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: size * 0.46,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: titleColor,
      ),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [sun, SizedBox(height: AppSpacing.x4), title],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [sun, SizedBox(width: AppSpacing.x3), Flexible(child: title)],
    );
  }
}
