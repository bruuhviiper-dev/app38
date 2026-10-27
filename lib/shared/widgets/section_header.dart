import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Cabeçalho de seção: título + ação opcional ("Ver todas ›").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: AppTextStyles.sectionTitle
                  .copyWith(color: Palette.of(context).textPrimary)),
        ),
        if (actionLabel != null && onAction != null)
          Semantics(
            button: true,
            label: actionLabel,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    Text(actionLabel!,
                        style: AppTextStyles.action
                            .copyWith(color: AppColors.gold)),
                    const SizedBox(width: 2),
                    const Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
