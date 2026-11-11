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
import '../services/verse_image_share.dart';
import '../shared/widgets/category_grid.dart';
import '../shared/widgets/home_header.dart';
import '../shared/widgets/inspiration_card.dart';
import '../shared/widgets/native_ad.dart';
import '../shared/widgets/section_header.dart';
import '../shared/widgets/verse_of_day_card.dart';
import 'all_verses_screen.dart';
import 'category_verses_screen.dart';
import 'image_editor_screen.dart';
import 'settings_screen.dart';
import 'verse_detail_screen.dart';

/// Corpo da Home (usado pela MainShell). Preserva o design aprovado; agora com
/// navegação real: todas as 14 categorias, inspiração -> detalhe, "Ver todas"
/// (inspirações) -> lista completa, sino -> Configurações.
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Verse? _override; // "Nova frase" (null = frase do dia)

  void _openDetail(Verse v) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: v)),
      );

  Future<void> _toggleFavorite(Verse v) async {
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
    final lang = t.lang;
    final state = context.watch<AppState>();

    if (VerseData.allFor(lang).isEmpty) {
      return _EmptyState(message: t.emptyVerses);
    }

    final hero = _override ?? VerseData.ofToday(lang);
    final featured = VerseData.categories; // todas as 14 na Home
    final more = VerseData.moreInspirations(lang, count: 6);

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
            verse: hero,
            isFavorite: state.isFavorite(hero.id),
            onShare: () => VerseImageShare.share(context, hero, appName: t.appName),
            onToggleFavorite: () => _toggleFavorite(hero),
            onNewVerse: () =>
                setState(() => _override = VerseData.random(lang)),
          ),
          const SizedBox(height: AppSpacing.x6),

          SectionHeader(title: t.exploreByCategory),
          const SizedBox(height: AppSpacing.x3),
          CategoryGrid(
            categories: featured,
            columns: 3,
            onTap: (cat) => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => CategoryVersesScreen(category: cat)),
            ),
          ),
          const SizedBox(height: AppSpacing.x6),

          SectionHeader(
            title: t.moreInspirations,
            actionLabel: t.seeAll,
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AllVersesScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          for (var i = 0; i < more.length; i++) ...[
            InspirationCard(
              verse: more[i],
              thumb: Landscapes.inspThumb(i),
              isFavorite: state.isFavorite(more[i].id),
              onShare: () => ShareHelper.shareVerse(more[i], appName: t.appName),
              onToggleFavorite: () => _toggleFavorite(more[i]),
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ImageEditorScreen(verse: more[i])),
              ),
              onTap: () => _openDetail(more[i]),
            ),
            if (i != more.length - 1) const SizedBox(height: AppSpacing.cardGap),
            // Anúncio nativo "disfarçado" no feed (some p/ quem removeu anúncios).
            if (i == 1) const NativeAdWidget(),
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
