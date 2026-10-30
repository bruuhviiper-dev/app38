import 'package:home_widget/home_widget.dart';

import '../data/verses.dart';

/// Atualiza o WIDGET de tela inicial com a FRASE DO DIA (renderização NATIVA
/// via RemoteViews — nunca renderFlutterWidget com foto, que trava em loop).
class WidgetService {
  WidgetService._();

  static const _androidName = 'QuoteWidgetProvider';

  /// Grava a frase do dia (no idioma) + nome do app e manda atualizar o widget.
  static Future<void> updateDailyQuote({
    required String lang,
    required String appName,
  }) async {
    try {
      final verse = VerseData.ofToday(lang);
      await HomeWidget.saveWidgetData<String>('quote_text', verse.text);
      await HomeWidget.saveWidgetData<String>('app_name', appName);
      await HomeWidget.updateWidget(androidName: _androidName);
    } catch (_) {
      // sem widget na tela / plataforma não suportada: ignora
    }
  }
}
