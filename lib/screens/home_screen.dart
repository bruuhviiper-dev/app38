import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/landscapes.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/share_helper.dart';
import '../shared/widgets/category_grid.dart';
import '../shared/widgets/home_header.dart';
import '../shared/widgets/inspiration_card.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/verse_of_day_card.dart';
import 'category_verses_screen.dart';
import 'settings_screen.dart';
import 'verse_detail_screen.dart';

/// Corpo da Home (usado pela MainShell). Preserva o design aprovado; agora com
/// navegação real: categorias -> lista, inspiração -> detalhe, "Ver todas" ->
/// aba Categorias, sino -> Configurações.
class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.onOpenCategories});

  final VoidCallback onOpenCategories;

  void _openDetail(BuildContext context, Verse v) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: v)),
      );

  Future<void> _toggleFavorite(BuildContext context, Verse v) async {
    final t = T.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = context.read<AppState>().toggleFavorite(v.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added ? t.savedToFavorites : t.removedFromFavorites),
        duration: const Duration(milliseconds: 1200),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final state = context.watch<AppState>();
    final today = VerseData.ofToday(t.lang);
    final categories = VerseData.categories;
    final more = VerseData.moreInspirations(t.lang, count: 6);

    if (VerseData.allFor(t.lang).isEmpty) {
      return _EmptyState(message: t.emptyVerses);
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12,
            AppSpacing.screenPadding, 28),
        children: [
          HomeHeader(
            onNotifications: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.x5),

          VerseOfDayCard(
            verse: today,
            isFavorite: state.isFavorite(today.id),
            onShare: () => ShareHelper.shareVerse(today, appName: t.appName),
            onToggleFavorite: () => _toggleFavorite(context, today),
          ),
          const SizedBox(height: AppSpacing.x6),

          SectionHeader(
            title: t.exploreByCategory,
            actionLabel: t.seeAll,
            onAction: onOpenCategories,
          ),
          const SizedBox(height: AppSpacing.x3),
          CategoryGrid(
            categories: categories,
            onTap: (cat) => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => CategoryVersesScreen(category: cat)),
            ),
          ),
          const SizedBox(height: AppSpacing.x6),

          SectionHeader(title: t.moreInspirations),
          const SizedBox(height: AppSpacing.x3),
          for (var i = 0; i < more.length; i++) ...[
            InspirationCard(
              verse: more[i],
              thumb: Landscapes.inspThumb(i),
              isFavorite: state.isFavorite(more[i].id),
              onShare: () => ShareHelper.shareVerse(more[i], appName: t.appName),
              onToggleFavorite: () => _toggleFavorite(context, more[i]),
              onTap: () => _openDetail(context, more[i]),
            ),
            if (i != more.length - 1) const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sunrise, size: 48, color: AppColors.gold),
            const SizedBox(height: AppSpacing.x4),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.body.copyWith(color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}
