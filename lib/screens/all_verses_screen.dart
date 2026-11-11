import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/share_helper.dart';
import '../shared/widgets/banner_ad.dart';
import '../shared/widgets/inspiration_card.dart';
import '../shared/widgets/native_ad.dart';
import 'image_editor_screen.dart';
import 'verse_detail_screen.dart';

/// "Ver todas": lista TODAS as frases (INTERCALADAS entre categorias) como cards
/// imersivos, com rolagem leve (ListView lazy). Favoritar/compartilhar/editar/
/// abrir. Monetização: banner no rodapé + 1 anúncio NATIVO a cada 15 frases.
class AllVersesScreen extends StatelessWidget {
  const AllVersesScreen({super.key});

  static const _adEvery = 15; // 1 nativo a cada 15 frases

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final verses = VerseData.allInterleaved(t.lang);
    final adsRemoved = state.adsRemoved;

    // Intercala anúncios nativos no fluxo (desligado p/ quem removeu anúncios).
    final slot = _adEvery + 1;
    final adCount = adsRemoved ? 0 : verses.length ~/ _adEvery;
    final total = verses.length + adCount;

    return Scaffold(
      appBar: AppBar(title: Text(t.moreInspirations), backgroundColor: p.bg),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: total,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, i) {
          if (!adsRemoved && i % slot == _adEvery) {
            return const NativeAdWidget();
          }
          final vi = adsRemoved ? i : i - (i ~/ slot);
          if (vi >= verses.length) return const SizedBox.shrink();
          final v = verses[vi];
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
