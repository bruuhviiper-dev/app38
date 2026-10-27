import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/image_export.dart';
import '../shared/widgets/landscape_image.dart';
import 'image_editor_screen.dart';

/// Detalhe da frase: foto da categoria em tela cheia + frase grande.
/// Ações reais: Compartilhar como IMAGEM, Editar (abre o editor), Copiar e
/// Favoritar.
class VerseDetailScreen extends StatefulWidget {
  const VerseDetailScreen({super.key, required this.verse});
  final Verse verse;

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _shareImage(T t) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await ImageExport.capture(_cardKey);
      if (bytes == null) return;
      await ImageExport.share(bytes, text: '${t.appName} — ${t.appSubtitle}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(T t) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: widget.verse.text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.copied)));
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final cat = VerseData.categoryById(widget.verse.categoryId);
    final isFav =
        context.select<AppState, bool>((s) => s.isFavorite(widget.verse.id));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camada capturável (foto + frase), sem botões.
          RepaintBoundary(
            key: _cardKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LandscapeImage(asset: cat.asset),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xBB04101E), Color(0x66000000),
                        Color(0xEE040C16)],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('“',
                          style: AppTextStyles.heroQuote.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 64,
                              height: 0.8)),
                      const SizedBox(height: 4),
                      Text(
                        widget.verse.text,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heroQuote.copyWith(
                            color: Colors.white, fontSize: 26, height: 1.35),
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 15, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(t.catName(widget.verse.categoryId),
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Overlay com botões (fora da captura).
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x2),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(LucideIcons.arrowLeft,
                          color: Colors.white),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x4, 0, AppSpacing.x4, AppSpacing.x5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Action(
                        icon: LucideIcons.share2,
                        label: t.share,
                        busy: _busy,
                        onTap: () => _shareImage(t),
                      ),
                      _Action(
                        icon: LucideIcons.wand,
                        label: t.editImage,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ImageEditorScreen(verse: widget.verse)),
                        ),
                      ),
                      _Action(
                        icon: LucideIcons.copy,
                        label: t.copy,
                        onTap: () => _copy(t),
                      ),
                      _Action(
                        icon: LucideIcons.heart,
                        label: t.save,
                        active: isFav,
                        onTap: () => context
                            .read<AppState>()
                            .toggleFavorite(widget.verse.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.gold : Colors.white;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
