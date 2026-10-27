import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/verses.dart';
import 'category_card.dart';

/// Grade de categorias. O número de colunas se ADAPTA à largura (não é fixo em
/// três): mais estreito -> 2 colunas; confortável -> 3.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.categories, this.onTap});

  final List<VerseCategory> categories;
  final void Function(VerseCategory category)? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 420 ? 3 : 2;
        const gap = AppSpacing.cardGap;
        final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
        // proporção ~1.0; altura mínima garante legibilidade do nome+descrição.
        final cellH = (cellW * 1.0).clamp(118.0, 150.0);
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: cellH,
          ),
          itemBuilder: (context, i) {
            final cat = categories[i];
            return CategoryCard(
              category: cat,
              onTap: onTap == null ? null : () => onTap!(cat),
            );
          },
        );
      },
    );
  }
}
