import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../shared/widgets/verse_list_card.dart';
import 'image_editor_screen.dart';
import 'verse_detail_screen.dart';

/// Lista de frases de uma categoria. Cada card abre o Detalhe.
class CategoryVersesScreen extends StatelessWidget {
  const CategoryVersesScreen({super.key, required this.category});
  final VerseCategory category;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final verses = VerseData.byCategory(t.lang, category.id);
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.catName(category.id)),
        backgroundColor: Palette.of(context).bg,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
            AppSpacing.x3, AppSpacing.screenPadding, AppSpacing.x7),
        itemCount: verses.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, i) {
          final v = verses[i];
          return VerseListCard(
            verse: v,
            isFavorite: state.isFavorite(v.id),
            onToggleFavorite: () =>
                context.read<AppState>().toggleFavorite(v.id),
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
