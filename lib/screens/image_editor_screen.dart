import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/landscapes.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/image_export.dart';
import '../shared/widgets/landscape_image.dart';

/// Filtro de cor estilo "grade" (como no Canva). [matrix] aplica um filtro de
/// matriz (sépia/P&B); [tint] é uma camada de cor por cima da foto (azulado/
/// amarelado/avermelhado). Ambos opcionais — nenhum = Original.
class _ImgFilter {
  const _ImgFilter(this.labelKey, {this.matrix, this.tint});
  final String labelKey;
  final ColorFilter? matrix;
  final Color? tint;
}

const _sepia = ColorFilter.matrix([
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0,
]);

const _grayscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// Editor: cria uma imagem com a frase sobre uma paisagem + filtro de cor.
/// Compartilha ou salva na galeria. Não altera a lógica/favoritos.
class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key, required this.verse});
  final Verse verse;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final _cardKey = GlobalKey();
  late int _bg = Landscapes.editorIndexForCategory(widget.verse.categoryId);
  int _filter = 0;
  bool _busy = false;

  List<_ImgFilter> _filters(T t) => [
        _ImgFilter(t.filterNone),
        _ImgFilter(t.filterBlue, tint: const Color(0x422D5FD6)),
        _ImgFilter(t.filterYellow, tint: const Color(0x40FFAC32)),
        _ImgFilter(t.filterRed, tint: const Color(0x44E2523A)),
        _ImgFilter(t.filterVintage, matrix: _sepia, tint: const Color(0x2EB98A3C)),
        _ImgFilter(t.filterBW, matrix: _grayscale),
      ];

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(T t) => _run(() async {
        final bytes = await ImageExport.capture(_cardKey);
        if (bytes == null) return;
        await ImageExport.share(bytes, text: '${t.appName} — ${t.appSubtitle}');
      });

  Future<void> _save(T t) => _run(() async {
        final messenger = ScaffoldMessenger.of(context);
        final bytes = await ImageExport.capture(_cardKey);
        if (bytes == null) return;
        try {
          await ImageExport.saveToGallery(bytes);
          messenger.showSnackBar(SnackBar(content: Text(t.savedToGallery)));
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(t.saveError)));
        }
      });

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final filters = _filters(t);
    final bgAsset = Landscapes.editorBackgrounds[_bg];

    return Scaffold(
      appBar: AppBar(title: Text(t.createImage), backgroundColor: p.bg),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.hero),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _filtered(bgAsset, filters[_filter]),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0x33000000), Color(0x55000000),
                                    Color(0xCC000000)],
                                  stops: [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.x6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('“',
                                      style: AppTextStyles.heroQuote.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: 52,
                                          height: 0.8)),
                                  Text(
                                    widget.verse.text,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heroQuote.copyWith(
                                        color: Colors.white,
                                        fontSize: 22,
                                        height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 14,
                              left: 0,
                              right: 0,
                              child: Text(t.appName,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Controls(
            backgrounds: Landscapes.editorBackgrounds,
            selectedBg: _bg,
            onBg: (i) => setState(() => _bg = i),
            filters: filters,
            selectedFilter: _filter,
            onFilter: (i) => setState(() => _filter = i),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 4,
                  AppSpacing.screenPadding, AppSpacing.x4),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : () => _share(t),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(LucideIcons.share2, size: 18),
                      label: Text(t.shareImage),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _save(t),
                      icon: const Icon(LucideIcons.download, size: 18),
                      label: Text(t.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtered(String asset, _ImgFilter f) {
    Widget img = LandscapeImage(asset: asset);
    if (f.matrix != null) {
      img = ColorFiltered(colorFilter: f.matrix!, child: img);
    }
    if (f.tint == null) return img;
    return Stack(
      fit: StackFit.expand,
      children: [img, ColoredBox(color: f.tint!)],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.backgrounds,
    required this.selectedBg,
    required this.onBg,
    required this.filters,
    required this.selectedFilter,
    required this.onFilter,
  });

  final List<String> backgrounds;
  final int selectedBg;
  final ValueChanged<int> onBg;
  final List<_ImgFilter> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilter;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.bg2,
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(t.backgroundsLabel, p),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: backgrounds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => onBg(i),
                child: Container(
                  width: 48,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    border: Border.all(
                        color: i == selectedBg
                            ? AppColors.gold
                            : Colors.transparent,
                        width: 2.5),
                  ),
                  child: LandscapeImage(asset: backgrounds[i]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _label(t.filtersLabel, p),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sel = i == selectedFilter;
                return GestureDetector(
                  onTap: () => onFilter(i),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.gold : p.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sel ? AppColors.gold : p.border),
                    ),
                    child: Text(filters[i].labelKey,
                        style: AppTextStyles.caption.copyWith(
                            color: sel ? AppColors.bg : p.textSecondary)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, Palette p) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 2,
            AppSpacing.screenPadding, 6),
        child: Text(text,
            style: AppTextStyles.overline.copyWith(color: p.textSecondary)),
      );
}
