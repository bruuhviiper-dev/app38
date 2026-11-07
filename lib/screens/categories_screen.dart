import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../shared/widgets/filter_chips.dart';
import '../shared/widgets/landscape_image.dart';
import 'category_verses_screen.dart';
import 'search_screen.dart';

/// Tela de Categorias: busca + filtros + lista (foto, nome, nº de frases).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _filter = 0;

  List<VerseCategory> _sorted(String lang) {
    final list = [...VerseData.categories];
    switch (_filter) {
      case 1: // Mais populares (por nº de frases)
        list.sort((a, b) => VerseData.byCategory(lang, b.id)
            .length
            .compareTo(VerseData.byCategory(lang, a.id).length));
      case 2: // Novas (ordem inversa)
        return list.reversed.toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final cats = _sorted(t.lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.categoriesTitle),
        backgroundColor: p.bg,
        actions: [
          IconButton(
            tooltip: t.searchTitle,
            icon: const Icon(LucideIcons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 4,
                AppSpacing.screenPadding, AppSpacing.x3),
            child: FilterChips(
              labels: [t.filterAll, t.filterPopular, t.filterNew],
              selected: _filter,
              onSelected: (i) => setState(() => _filter = i),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
                  AppSpacing.screenPadding, AppSpacing.x7),
              itemCount: cats.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.cardGap),
              itemBuilder: (context, i) {
                final cat = cats[i];
                return _CategoryRow(
                  category: cat,
                  count: VerseData.byCategory(t.lang, cat.id).length,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => CategoryVersesScreen(category: cat)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final VerseCategory category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: p.border),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.chip),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: LandscapeImage(asset: category.asset, thumb: 72),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.catName(category.id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.categoryName
                            .copyWith(color: p.textPrimary)),
                    const SizedBox(height: 3),
                    Text(t.versesCount(count),
                        style: AppTextStyles.caption
                            .copyWith(color: p.textSecondary)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 20, color: p.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
