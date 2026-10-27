import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../shared/widgets/verse_list_card.dart';
import 'verse_detail_screen.dart';

/// Pesquisa: campo + sugestões populares (categorias) + resultados do banco
/// local. Trata estado inicial (sugestões) e "sem resultados".
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Verse> _search(String q) {
    final needle = q.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final t = T.of(context);
    return VerseData.allFor(t.lang).where((v) {
      final inText = v.text.toLowerCase().contains(needle);
      final catName = t.catName(v.categoryId).toLowerCase();
      return inText || catName.contains(needle);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final results = _search(_query);

    return Scaffold(
      appBar: AppBar(title: Text(t.searchTitle), backgroundColor: p.bg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 4,
                AppSpacing.screenPadding, AppSpacing.x3),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              style: AppTextStyles.body.copyWith(color: p.textPrimary),
              decoration: InputDecoration(
                hintText: t.searchHint,
                hintStyle: AppTextStyles.body.copyWith(color: p.textSecondary),
                prefixIcon:
                    Icon(LucideIcons.search, size: 20, color: p.textSecondary),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(LucideIcons.x,
                            size: 18, color: p.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: p.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  borderSide: BorderSide(color: p.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  borderSide: BorderSide(color: p.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? _Suggestions(onPick: (name) {
                    _controller.text = name;
                    setState(() => _query = name);
                  })
                : results.isEmpty
                    ? _NoResults(query: _query.trim())
                    : _Results(results: results),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 4,
          AppSpacing.screenPadding, AppSpacing.x7),
      children: [
        Text(t.popularSuggestions,
            style: AppTextStyles.overline.copyWith(color: p.textSecondary)),
        const SizedBox(height: AppSpacing.x3),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in VerseData.categories)
              GestureDetector(
                onTap: () => onPick(t.catName(c.id)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.border),
                  ),
                  child: Text(t.catName(c.id),
                      style: AppTextStyles.caption
                          .copyWith(color: p.textPrimary)),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.x6),
        Center(
          child: Text(t.searchPrompt,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: p.textSecondary)),
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results});
  final List<Verse> results;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0,
          AppSpacing.screenPadding, AppSpacing.x7),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (context, i) {
        final v = results[i];
        return VerseListCard(
          verse: v,
          isFavorite: state.isFavorite(v.id),
          onToggleFavorite: () => context.read<AppState>().toggleFavorite(v.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VerseDetailScreen(verse: v)),
          ),
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 44, color: p.textSecondary),
            const SizedBox(height: AppSpacing.x4),
            Text(t.noResults(query),
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: p.textSecondary)),
          ],
        ),
      ),
    );
  }
}
