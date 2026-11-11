import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../shared/widgets/filter_chips.dart';
import '../shared/widgets/verse_list_card.dart';
import 'image_editor_screen.dart';
import 'verse_detail_screen.dart';

/// Favoritos: lista das frases salvas (persistidas). Filtros Todas / Texto
/// (A–Z) / Por categoria (agrupado). Estado vazio quando não há favoritos.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _filter = 0;

  void _openDetail(Verse v) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: v)),
      );

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final favs =
        VerseData.allFor(t.lang).where((v) => state.isFavorite(v.id)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bg,
        title: Row(
          children: [
            const Icon(LucideIcons.heart, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(t.favoritesTitle),
          ],
        ),
      ),
      body: favs.isEmpty
          ? _Empty(title: t.emptyFavorites, hint: t.emptyFavoritesHint)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
                      4, AppSpacing.screenPadding, AppSpacing.x3),
                  child: FilterChips(
                    labels: [t.filterAll, t.favText, t.favByCategory],
                    selected: _filter,
                    onSelected: (i) => setState(() => _filter = i),
                  ),
                ),
                Expanded(child: _buildList(context, favs, state)),
              ],
            ),
    );
  }

  Widget _buildList(BuildContext context, List<Verse> favs, AppState state) {
    const pad = EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
        AppSpacing.screenPadding, AppSpacing.x7);

    if (_filter == 2) {
      // Por categoria (agrupado)
      final t = T.of(context);
      final p = Palette.of(context);
      final byCat = <String, List<Verse>>{};
      for (final v in favs) {
        byCat.putIfAbsent(v.categoryId, () => []).add(v);
      }
      final ids = VerseData.categories
          .map((c) => c.id)
          .where(byCat.containsKey)
          .toList();
      return ListView(
        padding: pad,
        children: [
          for (final id in ids) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(t.catName(id),
                  style: AppTextStyles.overline
                      .copyWith(color: p.textSecondary)),
            ),
            for (final v in byCat[id]!) ...[
              VerseListCard(
                verse: v,
                isFavorite: true,
                onToggleFavorite: () =>
                    context.read<AppState>().toggleFavorite(v.id),
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ImageEditorScreen(verse: v)),
                ),
                onTap: () => _openDetail(v),
              ),
              const SizedBox(height: AppSpacing.cardGap),
            ],
          ],
        ],
      );
    }

    final list = [...favs];
    if (_filter == 1) {
      list.sort((a, b) =>
          a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    }
    return ListView.separated(
      padding: pad,
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (context, i) {
        final v = list[i];
        return VerseListCard(
          verse: v,
          isFavorite: true,
          onToggleFavorite: () => context.read<AppState>().toggleFavorite(v.id),
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ImageEditorScreen(verse: v)),
          ),
          onTap: () => _openDetail(v),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.hint});
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.heart, size: 46, color: AppColors.gold),
            const SizedBox(height: AppSpacing.x4),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle
                    .copyWith(color: p.textPrimary)),
            const SizedBox(height: AppSpacing.x2),
            Text(hint,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}
