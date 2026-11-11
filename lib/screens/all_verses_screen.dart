import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/share_helper.dart';
import '../shared/widgets/inspiration_card.dart';
import 'image_editor_screen.dart';
import 'verse_detail_screen.dart';

/// "Ver todas": lista TODAS as frases (de todas as categorias) como cards
/// imersivos, com rolagem leve (ListView lazy). Favoritar/compartilhar/abrir.
class AllVersesScreen extends StatelessWidget {
  const AllVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final verses = VerseData.allFor(t.lang);

    return Scaffold(
      appBar: AppBar(title: Text(t.moreInspirations), backgroundColor: p.bg),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: verses.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, i) {
          final v = verses[i];
          return InspirationCard(
            verse: v,
            thumb: VerseData.categoryById(v.categoryId).asset,
            isFavorite: state.isFavorite(v.id),
            onShare: () => ShareHelper.shareVerse(v, appName: t.appName),
            onToggleFavorite: () => context.read<AppState>().toggleFavorite(v.id),
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ImageEditorScreen(verse: v)),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: v)),
            ),
          );
        },
      ),
    );
  }
}
