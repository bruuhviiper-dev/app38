import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_text_styles.dart';
import '../data/landscapes.dart';
import '../data/verses.dart';
import '../shared/widgets/landscape_image.dart';
import 'image_export.dart';
import 'rate_prompt.dart';

/// Gera uma IMAGEM limpa (frase sobre a paisagem, sem botões) e compartilha,
/// SEM abrir o editor: renderiza o card fora da tela via OverlayEntry, captura
/// em alta e remove. Usado pelo card principal (Frase do Dia) e outros.
class VerseImageShare {
  VerseImageShare._();

  static Future<void> share(BuildContext context, Verse verse,
      {required String appName}) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final bgAsset = Landscapes
        .editorBackgrounds[Landscapes.editorIndexForCategory(verse.categoryId)];

    // Garante a foto decodificada ANTES de capturar (senão sai fundo vazio).
    try {
      await precacheImage(AssetImage(bgAsset), context);
    } catch (_) {}
    if (!context.mounted) return;

    final key = GlobalKey();
    final completer = Completer<void>();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -2000, // fora da tela, mas ainda pintado
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: key,
            child: _ShareCard(verse: verse, bgAsset: bgAsset, appName: appName),
          ),
        ),
      ),
    );
    overlay.insert(entry);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 2 frames + folga p/ garantir layout + paint da imagem.
      await Future<void>.delayed(const Duration(milliseconds: 240));
      try {
        final bytes = await ImageExport.capture(key);
        if (bytes != null) {
          await ImageExport.share(bytes, text: appName);
          await RatePrompt.registerPositiveAction();
        }
      } finally {
        entry.remove();
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }
}

/// Card 4:5 limpo (sem botões) para a imagem compartilhada.
class _ShareCard extends StatelessWidget {
  const _ShareCard(
      {required this.verse, required this.bgAsset, required this.appName});
  final Verse verse;
  final String bgAsset;
  final String appName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LandscapeImage(asset: bgAsset),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0x55000000), Color(0xCC000000)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('“',
                    style: AppTextStyles.heroQuote.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 60,
                        height: 0.8)),
                Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heroQuote
                      .copyWith(color: Colors.white, fontSize: 24, height: 1.35),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Text(appName,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }
}
