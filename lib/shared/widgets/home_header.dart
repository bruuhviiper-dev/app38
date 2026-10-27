import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/strings.dart';

/// Cabeçalho da Home: logo (nascer do sol dourado) + nome do app + subtítulo,
/// e um botão de notificações opcional (só quando houver funcionalidade real).
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onNotifications});

  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gold, AppColors.goldDark],
            ),
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
          child: const Icon(LucideIcons.sunrise, color: AppColors.bg, size: 24),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.appTitle
                      .copyWith(color: p.textPrimary)),
              Text(t.appSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.appSubtitle
                      .copyWith(color: p.textSecondary)),
            ],
          ),
        ),
        if (onNotifications != null) ...[
          const SizedBox(width: AppSpacing.x2),
          Semantics(
            button: true,
            label: t.notifications,
            child: IconButton(
              onPressed: onNotifications,
              tooltip: t.notifications,
              iconSize: 22,
              style: IconButton.styleFrom(
                minimumSize: const Size(AppSpacing.minTouch, AppSpacing.minTouch),
                backgroundColor: p.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.chip)),
              ),
              icon: const Icon(LucideIcons.bell, color: AppColors.gold),
            ),
          ),
        ],
      ],
    );
  }
}
