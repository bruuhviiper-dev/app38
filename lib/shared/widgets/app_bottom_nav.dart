import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/strings.dart';

/// Navegação inferior: Início (selecionado/dourado), Explorar, Favoritos,
/// Ajustes. Respeita a área segura e não cobre o conteúdo.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final items = <(IconData, String)>[
      (LucideIcons.house, t.navHome),
      (LucideIcons.layoutGrid, t.navCategories),
      (LucideIcons.heart, t.navFavorites),
      (LucideIcons.menu, t.navMore),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.bg2,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: items[i].$1,
                    label: items[i].$2,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.gold : Palette.of(context).textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (selected
                        ? AppTextStyles.navActive
                        : AppTextStyles.navInactive)
                    .copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
