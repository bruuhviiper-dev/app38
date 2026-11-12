import 'package:share_plus/share_plus.dart';

import '../data/verses.dart';
import 'rate_prompt.dart';

/// Compartilhamento de frases. Compartilhar é uma AÇÃO POSITIVA → alimenta o
/// prompt de avaliação do Google.
class ShareHelper {
  ShareHelper._();

  static Future<void> shareVerse(Verse verse, {String appName = 'Frases do Dia'}) async {
    await SharePlus.instance.share(
      ShareParams(text: '"${verse.text}"\n\n— $appName'),
    );
    await RatePrompt.registerPositiveAction();
  }
}
