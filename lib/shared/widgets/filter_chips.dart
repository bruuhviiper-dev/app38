import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Linha de chips de filtro (o selecionado fica dourado). Rola na horizontal.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? AppColors.gold : p.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? AppColors.gold : p.border),
              ),
              child: Text(
                labels[i],
                style: AppTextStyles.caption.copyWith(
                    color: sel ? AppColors.bg : p.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
