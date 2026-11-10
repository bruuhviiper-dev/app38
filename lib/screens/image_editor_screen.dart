import 'dart:math' as math;

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

/// Filtro de cor: [matrix] (sépia/P&B via ColorFilter.matrix) e/ou [tint]
/// (camada de cor translúcida). `filter == null` = original.
class _ImgFilter {
  const _ImgFilter(this.labelKey, {this.matrix, this.tint});
  final String labelKey;
  final List<double>? matrix;
  final Color? tint;
}

// ---- Matrizes de cor (4x5) ----
const List<double> _identity = [
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0,
];
const List<double> _sepia = [
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0,
];
const List<double> _grayscale = [
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
];

List<double> _mul(List<double> a, List<double> b) {
  final o = List<double>.filled(20, 0);
  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 5; c++) {
      var s = 0.0;
      for (var k = 0; k < 4; k++) {
        s += a[r * 5 + k] * b[k * 5 + c];
      }
      if (c == 4) s += a[r * 5 + 4];
      o[r * 5 + c] = s;
    }
  }
  return o;
}

List<double> _lerpToIdentity(List<double> m, double t) =>
    [for (var i = 0; i < 20; i++) _identity[i] + (m[i] - _identity[i]) * t];

List<double> _saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final ir = (1 - s) * lr, ig = (1 - s) * lg, ib = (1 - s) * lb;
  return [
    ir + s, ig, ib, 0, 0, //
    ir, ig + s, ib, 0, 0, //
    ir, ig, ib + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

List<double> _contrastBrightness(double c, double b) {
  final t = (0.5 - 0.5 * c) * 255 + b * 255;
  return [
    c, 0, 0, 0, t, //
    0, c, 0, 0, t, //
    0, 0, c, 0, t, //
    0, 0, 0, 1, 0,
  ];
}

class _Format {
  const _Format(this.labelKey, this.ratio);
  final String labelKey;
  final double ratio;
}

/// Editor PRO: cria uma imagem com a frase sobre um FUNDO (foto, cor sólida,
/// degradê ou textura), com formatos, 12 filtros (intensidade), ajustes
/// (brilho/contraste/saturação), texturas sobrepostas e texto
/// (cor/tamanho/alinhamento). Preview em tempo real; export em alta
/// (pixelRatio 3). Não altera a lógica/favoritos.
class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key, required this.verse});
  final Verse verse;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final _cardKey = GlobalKey();
  late int _bg = Landscapes.editorIndexForCategory(widget.verse.categoryId);
  int _bgKind = 0; // 0=foto, 1=cor, 2=gradiente
  int _bgSub = 0; // sub-aba visível: 0=fotos 1=cores 2=degradês 3=texturas
  int _bgColor = 0;
  int _bgGradient = 0;
  int _texture = 0; // 0=nenhuma
  int _filter = 0;
  double _intensity = 1.0;
  double _brightness = 0.0; // -0.5..0.5
  double _contrast = 1.0; // 0.5..1.5
  double _saturation = 1.0; // 0..2
  int _format = 0;
  int _textColor = 0;
  double _textScale = 1.0; // 0.7..1.4
  TextAlign _align = TextAlign.center;
  int _tab = 0;
  bool _busy = false;

  static const _formats = [
    _Format('fmtStory', 9 / 16),
    _Format('fmtFeed', 1),
    _Format('fmtStatus', 4 / 5),
  ];
  static const _textColors = [
    Colors.white,
    Color(0xFFFFC02E),
    Colors.black,
    Color(0xFFBFE3FF),
    Color(0xFFFFD9C2),
  ];

  // Fundos de COR sólida (curados).
  static const _solidColors = <Color>[
    Color(0xFF06111F), // navy
    Color(0xFF14263A),
    Color(0xFF2D5FD6), // azul
    Color(0xFF0E7C66), // teal
    Color(0xFF7A3B8E), // roxo
    Color(0xFFB23A48), // vinho
    Color(0xFFD98324), // âmbar
    Color(0xFF2E2E2E), // carvão
    Color(0xFFF2E9DE), // creme
    Color(0xFF111111), // preto
  ];

  // Fundos de GRADIENTE (curados).
  static const _gradients = <List<Color>>[
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFF141E30), Color(0xFF243B55)],
    [Color(0xFF42275A), Color(0xFF734B6D)],
    [Color(0xFFDD5E89), Color(0xFFF7BB97)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFFCC2B5E), Color(0xFF753A88)],
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    [Color(0xFF1D976C), Color(0xFF93F9B9)],
  ];

  List<_ImgFilter> _filters(T t) {
    final fade = _mul(_contrastBrightness(0.82, 0.10), _saturationMatrix(0.88));
    final drama =
        _mul(_contrastBrightness(1.35, -0.04), _saturationMatrix(1.25));
    final noir = _mul(_contrastBrightness(1.28, 0.0), _grayscale);
    return [
      _ImgFilter(t.filterNone),
      _ImgFilter(t.filterBlue, tint: const Color(0xFF2D5FD6)),
      _ImgFilter(t.filterYellow, tint: const Color(0xFFFFAC32)),
      _ImgFilter(t.filterRed, tint: const Color(0xFFE2523A)),
      _ImgFilter(t.filterWarm, tint: const Color(0xFFFF8A3D)),
      _ImgFilter(t.filterMint, tint: const Color(0xFF2BD1A8)),
      _ImgFilter(t.filterPurple, tint: const Color(0xFF8E5BD6)),
      _ImgFilter(t.filterVintage,
          matrix: _sepia, tint: const Color(0xFFB98A3C)),
      _ImgFilter(t.filterFade, matrix: fade),
      _ImgFilter(t.filterDrama, matrix: drama),
      _ImgFilter(t.filterNoir, matrix: noir),
      _ImgFilter(t.filterBW, matrix: _grayscale),
    ];
  }

  void _reset() => setState(() {
        _filter = 0;
        _intensity = 1.0;
        _brightness = 0.0;
        _contrast = 1.0;
        _saturation = 1.0;
        _texture = 0;
        _textColor = 0;
        _textScale = 1.0;
        _align = TextAlign.center;
      });

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

  ColorFilter _buildColorFilter(_ImgFilter f) {
    var m = _mul(_contrastBrightness(_contrast, _brightness),
        _saturationMatrix(_saturation));
    if (f.matrix != null) {
      m = _mul(m, _lerpToIdentity(f.matrix!, _intensity));
    }
    return ColorFilter.matrix(m);
  }

  /// Widget-base do fundo ANTES do filtro de cor (foto / cor / gradiente).
  Widget _baseChild() {
    switch (_bgKind) {
      case 1:
        return ColoredBox(color: _solidColors[_bgColor]);
      case 2:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradients[_bgGradient],
            ),
          ),
        );
      default:
        return LandscapeImage(asset: Landscapes.editorBackgrounds[_bg]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final filters = _filters(t);
    final f = filters[_filter];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.createImage),
        backgroundColor: p.bg,
        actions: [
          IconButton(
            tooltip: t.reset,
            icon: const Icon(LucideIcons.rotateCcw),
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Preview ----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: AspectRatio(
                      aspectRatio: _formats[_format].ratio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.hero),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: _buildColorFilter(f),
                              child: _baseChild(),
                            ),
                            if (f.tint != null)
                              ColoredBox(
                                color: f.tint!
                                    .withValues(alpha: 0.26 * _intensity),
                              ),
                            if (_texture != 0)
                              Positioned.fill(
                                child: CustomPaint(
                                    painter: _TexturePainter(_texture)),
                              ),
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
                                crossAxisAlignment: _align == TextAlign.left
                                    ? CrossAxisAlignment.start
                                    : _align == TextAlign.right
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.center,
                                children: [
                                  Text('“',
                                      style: AppTextStyles.heroQuote.copyWith(
                                          color: _textColors[_textColor]
                                              .withValues(alpha: 0.7),
                                          fontSize: 52 * _textScale,
                                          height: 0.8)),
                                  Text(
                                    widget.verse.text,
                                    textAlign: _align,
                                    style: AppTextStyles.heroQuote.copyWith(
                                        color: _textColors[_textColor],
                                        fontSize: 22 * _textScale,
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
                                      color: Colors.white
                                          .withValues(alpha: 0.8))),
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
          // ---- Formatos ----
          _FormatBar(
            formats: [t.fmtStory, t.fmtFeed, t.fmtStatus],
            selected: _format,
            onSelected: (i) => setState(() => _format = i),
          ),
          // ---- Abas de edição ----
          _ControlPanel(
            tab: _tab,
            onTab: (i) => setState(() => _tab = i),
            backgrounds: Landscapes.editorBackgrounds,
            bgKind: _bgKind,
            bgSub: _bgSub,
            onBgSub: (i) => setState(() => _bgSub = i),
            selectedBg: _bg,
            onBg: (i) => setState(() {
              _bgKind = 0;
              _bg = i;
            }),
            solidColors: _solidColors,
            selectedColor: _bgColor,
            onColor: (i) => setState(() {
              _bgKind = 1;
              _bgColor = i;
            }),
            gradients: _gradients,
            selectedGradient: _bgGradient,
            onGradient: (i) => setState(() {
              _bgKind = 2;
              _bgGradient = i;
            }),
            texture: _texture,
            onTexture: (i) => setState(() => _texture = i),
            filters: filters,
            selectedFilter: _filter,
            onFilter: (i) => setState(() => _filter = i),
            intensity: _intensity,
            onIntensity: (v) => setState(() => _intensity = v),
            brightness: _brightness,
            onBrightness: (v) => setState(() => _brightness = v),
            contrast: _contrast,
            onContrast: (v) => setState(() => _contrast = v),
            saturation: _saturation,
            onSaturation: (v) => setState(() => _saturation = v),
            textColors: _textColors,
            selectedTextColor: _textColor,
            onTextColor: (i) => setState(() => _textColor = i),
            textScale: _textScale,
            onTextScale: (v) => setState(() => _textScale = v),
            align: _align,
            onAlign: (a) => setState(() => _align = a),
          ),
          // ---- Ações ----
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 6,
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
                      label: Text(t.shareImage,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _save(t),
                      icon: const Icon(LucideIcons.download, size: 18),
                      label: Text(t.save,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
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
}

class _FormatBar extends StatelessWidget {
  const _FormatBar(
      {required this.formats, required this.selected, required this.onSelected});
  final List<String> formats;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      color: p.bg2,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < formats.length; i++) ...[
            GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.gold : p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: i == selected ? AppColors.gold : p.border),
                ),
                child: Text(formats[i],
                    style: AppTextStyles.caption.copyWith(
                        color: i == selected ? AppColors.bg : p.textSecondary)),
              ),
            ),
            if (i != formats.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.tab,
    required this.onTab,
    required this.backgrounds,
    required this.bgKind,
    required this.bgSub,
    required this.onBgSub,
    required this.selectedBg,
    required this.onBg,
    required this.solidColors,
    required this.selectedColor,
    required this.onColor,
    required this.gradients,
    required this.selectedGradient,
    required this.onGradient,
    required this.texture,
    required this.onTexture,
    required this.filters,
    required this.selectedFilter,
    required this.onFilter,
    required this.intensity,
    required this.onIntensity,
    required this.brightness,
    required this.onBrightness,
    required this.contrast,
    required this.onContrast,
    required this.saturation,
    required this.onSaturation,
    required this.textColors,
    required this.selectedTextColor,
    required this.onTextColor,
    required this.textScale,
    required this.onTextScale,
    required this.align,
    required this.onAlign,
  });

  final int tab;
  final ValueChanged<int> onTab;
  final List<String> backgrounds;
  final int bgKind;
  final int bgSub;
  final ValueChanged<int> onBgSub;
  final int selectedBg;
  final ValueChanged<int> onBg;
  final List<Color> solidColors;
  final int selectedColor;
  final ValueChanged<int> onColor;
  final List<List<Color>> gradients;
  final int selectedGradient;
  final ValueChanged<int> onGradient;
  final int texture;
  final ValueChanged<int> onTexture;
  final List<_ImgFilter> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilter;
  final double intensity;
  final ValueChanged<double> onIntensity;
  final double brightness;
  final ValueChanged<double> onBrightness;
  final double contrast;
  final ValueChanged<double> onContrast;
  final double saturation;
  final ValueChanged<double> onSaturation;
  final List<Color> textColors;
  final int selectedTextColor;
  final ValueChanged<int> onTextColor;
  final double textScale;
  final ValueChanged<double> onTextScale;
  final TextAlign align;
  final ValueChanged<TextAlign> onAlign;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final tabs = [
      (LucideIcons.image, t.backgroundsLabel),
      (LucideIcons.wand, t.filtersLabel),
      (LucideIcons.slidersHorizontal, t.adjustmentsLabel),
      (LucideIcons.type, t.textLabel),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.bg2,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTab(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Icon(tabs[i].$1,
                              size: 20,
                              color: i == tab
                                  ? AppColors.gold
                                  : p.textSecondary),
                          const SizedBox(height: 3),
                          Text(tabs[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  color: i == tab
                                      ? AppColors.gold
                                      : p.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 1, color: p.border),
          SizedBox(height: 124, child: _tabContent(context, t, p)),
        ],
      ),
    );
  }

  Widget _tabContent(BuildContext context, T t, Palette p) {
    switch (tab) {
      case 0:
        return _bgTab(context, t, p);
      case 1:
        return _filtersTab(context, t, p);
      case 2:
        return _adjustTab(t, p);
      default:
        return _textTab(t, p);
    }
  }

  // ---- Aba FUNDO: sub-seletor (Fotos/Cores/Degradês/Texturas) + conteúdo ----
  Widget _bgTab(BuildContext context, T t, Palette p) {
    final segs = [t.bgPhotos, t.bgColors, t.bgGradients, t.bgTextures];
    // sub-aba corrente: texturas = índice 3 (independente de bgKind do fundo).
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3, vertical: 4),
            itemCount: segs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final sel = bgSub == i;
              return GestureDetector(
                onTap: () => onBgSub(i),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.gold : p.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: sel ? AppColors.gold : p.border),
                  ),
                  child: Text(segs[i],
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: sel ? AppColors.bg : p.textSecondary)),
                ),
              );
            },
          ),
        ),
        Expanded(child: _bgSubBody(context, t, p)),
      ],
    );
  }

  Widget _bgSubBody(BuildContext context, T t, Palette p) {
    switch (bgSub) {
      case 1:
        return _colorsRow(p);
      case 2:
        return _gradientsRow(p);
      case 3:
        return _texturesRow(t, p);
      default:
        return _thumbs(context);
    }
  }

  Widget _thumbs(BuildContext context) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacing.x3),
        itemCount: backgrounds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => onBg(i),
          child: Container(
            width: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                  color: (bgKind == 0 && i == selectedBg)
                      ? AppColors.gold
                      : Colors.transparent,
                  width: 2.5),
            ),
            child: LandscapeImage(asset: backgrounds[i], thumb: 72),
          ),
        ),
      );

  Widget _colorsRow(Palette p) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacing.x3),
        itemCount: solidColors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => onColor(i),
          child: Container(
            width: 58,
            decoration: BoxDecoration(
              color: solidColors[i],
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                  color: (bgKind == 1 && i == selectedColor)
                      ? AppColors.gold
                      : p.border,
                  width: (bgKind == 1 && i == selectedColor) ? 2.5 : 1),
            ),
          ),
        ),
      );

  Widget _gradientsRow(Palette p) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacing.x3),
        itemCount: gradients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => onGradient(i),
          child: Container(
            width: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients[i],
              ),
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                  color: (bgKind == 2 && i == selectedGradient)
                      ? AppColors.gold
                      : p.border,
                  width: (bgKind == 2 && i == selectedGradient) ? 2.5 : 1),
            ),
          ),
        ),
      );

  Widget _texturesRow(T t, Palette p) {
    final labels = [
      t.texNone,
      t.texGrain,
      t.texDots,
      t.texLines,
      t.texBokeh,
      t.texGlow,
      t.texVignette,
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.x3),
      itemCount: labels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final sel = texture == i;
        return GestureDetector(
          onTap: () => onTexture(i),
          child: Container(
            width: 70,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(
                  color: sel ? AppColors.gold : p.border,
                  width: sel ? 2.5 : 1),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (i != 0)
                  CustomPaint(painter: _TexturePainter(i, preview: true)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: sel ? AppColors.gold : Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filtersTab(BuildContext context, T t, Palette p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
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
                        border: Border.all(
                            color: sel ? AppColors.gold : p.border),
                      ),
                      child: Text(filters[i].labelKey,
                          style: AppTextStyles.caption.copyWith(
                              color: sel ? AppColors.bg : p.textSecondary)),
                    ),
                  );
                },
              ),
            ),
            _SliderRow(
              label: t.intensity,
              value: intensity,
              min: 0,
              max: 1,
              onChanged: selectedFilter == 0 ? null : onIntensity,
            ),
          ],
        ),
      );

  Widget _adjustTab(T t, Palette p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SliderRow(
                label: t.brightness,
                value: brightness,
                min: -0.5,
                max: 0.5,
                onChanged: onBrightness),
            _SliderRow(
                label: t.contrast,
                value: contrast,
                min: 0.5,
                max: 1.5,
                onChanged: onContrast),
            _SliderRow(
                label: t.saturation,
                value: saturation,
                min: 0,
                max: 2,
                onChanged: onSaturation),
          ],
        ),
      );

  Widget _textTab(T t, Palette p) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.x4, 10, AppSpacing.x4, 6),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < textColors.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => onTextColor(i),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: textColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: i == selectedTextColor
                                  ? AppColors.gold
                                  : p.border,
                              width: i == selectedTextColor ? 3 : 1),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                _alignBtn(LucideIcons.alignLeft, TextAlign.left),
                _alignBtn(LucideIcons.alignCenter, TextAlign.center),
                _alignBtn(LucideIcons.alignRight, TextAlign.right),
              ],
            ),
            _SliderRow(
                label: t.textSize,
                value: textScale,
                min: 0.7,
                max: 1.4,
                onChanged: onTextScale),
          ],
        ),
      );

  Widget _alignBtn(IconData icon, TextAlign a) => Padding(
        padding: const EdgeInsets.only(left: 6),
        child: GestureDetector(
          onTap: () => onAlign(a),
          child: Icon(icon,
              size: 22,
              color: align == a ? AppColors.gold : AppColors.textSecondary),
        ),
      );
}

/// Textura procedural (sem assets): grão, pontos, linhas, bokeh, brilho e
/// vinheta. Determinística (seed fixo) para o preview bater com o export.
class _TexturePainter extends CustomPainter {
  _TexturePainter(this.kind, {this.preview = false});
  final int kind; // 1=grão 2=pontos 3=linhas 4=bokeh 5=brilho 6=vinheta
  final bool preview;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case 1:
        _grain(canvas, size);
        break;
      case 2:
        _dots(canvas, size);
        break;
      case 3:
        _lines(canvas, size);
        break;
      case 4:
        _bokeh(canvas, size);
        break;
      case 5:
        _glow(canvas, size);
        break;
      case 6:
        _vignette(canvas, size);
        break;
    }
  }

  void _grain(Canvas c, Size s) {
    final rnd = math.Random(7);
    final paint = Paint();
    final n = (s.width * s.height / 70).clamp(150, 5000).toInt();
    for (var i = 0; i < n; i++) {
      final x = rnd.nextDouble() * s.width;
      final y = rnd.nextDouble() * s.height;
      final bright = rnd.nextBool();
      paint.color = (bright ? Colors.white : Colors.black)
          .withValues(alpha: 0.04 + rnd.nextDouble() * 0.06);
      c.drawRect(Rect.fromLTWH(x, y, 1.3, 1.3), paint);
    }
  }

  void _dots(Canvas c, Size s) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.10);
    final gap = preview ? 8.0 : 15.0;
    final r = preview ? 1.0 : 1.7;
    for (double y = gap; y < s.height; y += gap) {
      for (double x = gap; x < s.width; x += gap) {
        c.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  void _lines(Canvas c, Size s) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    final gap = preview ? 9.0 : 16.0;
    for (double x = -s.height; x < s.width; x += gap) {
      c.drawLine(Offset(x, 0), Offset(x + s.height, s.height), paint);
    }
  }

  void _bokeh(Canvas c, Size s) {
    final rnd = math.Random(11);
    final count = preview ? 7 : 16;
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * s.width;
      final y = rnd.nextDouble() * s.height;
      final r = (preview ? 3 : 8) + rnd.nextDouble() * (preview ? 8 : 28);
      final paint = Paint()
        ..color = Colors.white
            .withValues(alpha: 0.05 + rnd.nextDouble() * 0.09)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4);
      c.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _glow(Canvas c, Size s) {
    final rect = Rect.fromCircle(
        center: Offset(s.width * 0.8, s.height * 0.2), radius: s.width * 0.75);
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x66FFE6B0), Color(0x00FFE6B0)],
      ).createShader(rect);
    c.drawRect(Offset.zero & s, paint);
  }

  void _vignette(Canvas c, Size s) {
    final rect =
        Rect.fromCircle(center: s.center(Offset.zero), radius: s.longestSide * 0.72);
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x00000000), Color(0x99000000)],
        stops: [0.55, 1.0],
      ).createShader(rect);
    c.drawRect(Offset.zero & s, paint);
  }

  @override
  bool shouldRepaint(covariant _TexturePainter old) =>
      old.kind != kind || old.preview != preview;
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                  color: onChanged == null ? p.textSecondary.withValues(alpha: 0.4) : p.textSecondary)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.gold,
              thumbColor: AppColors.gold,
              inactiveTrackColor: p.border,
              trackHeight: 3,
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
