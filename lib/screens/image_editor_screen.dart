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

/// Editor PRO: cria uma imagem com a frase sobre uma paisagem. Formatos,
/// filtros com intensidade, ajustes (brilho/contraste/saturação), texto
/// (cor/tamanho/alinhamento), resetar, compartilhar e salvar. Preview em tempo
/// real; export em alta (pixelRatio 3). Não altera a lógica/favoritos.
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

  List<_ImgFilter> _filters(T t) => [
        _ImgFilter(t.filterNone),
        _ImgFilter(t.filterBlue, tint: const Color(0xFF2D5FD6)),
        _ImgFilter(t.filterYellow, tint: const Color(0xFFFFAC32)),
        _ImgFilter(t.filterRed, tint: const Color(0xFFE2523A)),
        _ImgFilter(t.filterVintage, matrix: _sepia, tint: const Color(0xFFB98A3C)),
        _ImgFilter(t.filterBW, matrix: _grayscale),
      ];

  void _reset() => setState(() {
        _filter = 0;
        _intensity = 1.0;
        _brightness = 0.0;
        _contrast = 1.0;
        _saturation = 1.0;
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

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final filters = _filters(t);
    final f = filters[_filter];
    final bgAsset = Landscapes.editorBackgrounds[_bg];

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
                              child: LandscapeImage(asset: bgAsset),
                            ),
                            if (f.tint != null)
                              ColoredBox(
                                color: f.tint!
                                    .withValues(alpha: 0.26 * _intensity),
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
            selectedBg: _bg,
            onBg: (i) => setState(() => _bg = i),
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
    required this.selectedBg,
    required this.onBg,
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
  final int selectedBg;
  final ValueChanged<int> onBg;
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
          SizedBox(height: 118, child: _tabContent(context, t, p)),
        ],
      ),
    );
  }

  Widget _tabContent(BuildContext context, T t, Palette p) {
    switch (tab) {
      case 0:
        return _thumbs(context);
      case 1:
        return _filtersTab(context, t, p);
      case 2:
        return _adjustTab(t, p);
      default:
        return _textTab(t, p);
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
                  color: i == selectedBg ? AppColors.gold : Colors.transparent,
                  width: 2.5),
            ),
            child: LandscapeImage(asset: backgrounds[i], thumb: 72),
          ),
        ),
      );

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
