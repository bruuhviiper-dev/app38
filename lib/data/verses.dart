import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Uma frase resolvida para um idioma. O [id] (`categoria#índice`) é ESTÁVEL
/// entre idiomas — os favoritos funcionam ao trocar de idioma; o texto é o do
/// idioma atual.
class Verse {
  const Verse(this.categoryId, this.index, this.text);
  final String categoryId;
  final int index;
  final String text;

  String get id => '$categoryId#$index';
}

/// Metadados de categoria. [id] é a chave de i18n (`cat.<id>.name`/`.desc`) e
/// a chave do conteúdo nos JSON (`assets/frases/<lang>.json`).
class VerseCategory {
  const VerseCategory(this.id, this.icon, this.asset);
  final String id;
  final IconData icon;
  final String asset;
}

/// Banco local de frases carregado de `assets/frases/<lang>.json` (pt/en/es),
/// ~5.900 frases ORIGINAIS por idioma em 14 categorias. Offline. `init()` deve
/// ser chamado no startup (ver main) antes de usar.
class VerseData {
  VerseData._();

  static const categories = <VerseCategory>[
    VerseCategory('motivacao', LucideIcons.mountain,
        'assets/landscapes/cat_motivacao.jpg'),
    VerseCategory('superacao', LucideIcons.trendingUp,
        'assets/landscapes/editor_bg03.jpg'),
    VerseCategory('sucesso', LucideIcons.trophy,
        'assets/landscapes/editor_bg02.jpg'),
    VerseCategory('coragem', LucideIcons.flame,
        'assets/landscapes/editor_bg01.jpg'),
    VerseCategory('trabalho', LucideIcons.briefcase,
        'assets/landscapes/cat_trabalho.jpg'),
    VerseCategory('amor', LucideIcons.heart, 'assets/landscapes/cat_amor.jpg'),
    VerseCategory('amizade', LucideIcons.users,
        'assets/landscapes/insp_coast.jpg'),
    VerseCategory('gratidao', LucideIcons.sparkles,
        'assets/landscapes/editor_bg07.jpg'),
    VerseCategory('felicidade', LucideIcons.sun,
        'assets/landscapes/cat_felicidade.jpg'),
    VerseCategory('vida', LucideIcons.sprout, 'assets/landscapes/cat_vida.jpg'),
    VerseCategory('reflexao', LucideIcons.feather,
        'assets/landscapes/cat_reflexao.jpg'),
    VerseCategory('sabedoria', LucideIcons.bookOpen,
        'assets/landscapes/editor_bg08.jpg'),
    VerseCategory('paz', LucideIcons.leaf, 'assets/landscapes/editor_bg06.jpg'),
    VerseCategory('esperanca', LucideIcons.sunrise,
        'assets/landscapes/editor_bg04.jpg'),
  ];

  static final Map<String, Map<String, List<String>>> _content = {};
  static bool _loaded = false;

  /// Carrega o conteúdo dos JSON (pt/en/es). Idempotente.
  static Future<void> init() async {
    if (_loaded) return;
    for (final lang in const ['pt', 'en', 'es']) {
      try {
        final raw = await rootBundle.loadString('assets/frases/$lang.json');
        final map = json.decode(raw) as Map<String, dynamic>;
        _content[lang] = map.map(
            (k, v) => MapEntry(k, (v as List).map((e) => e as String).toList()));
      } catch (_) {
        // idioma ausente: usa fallback
      }
    }
    _loaded = true;
  }

  static bool hasContent(String lang) => _content.containsKey(lang);

  static Map<String, List<String>> _data(String lang) =>
      _content[lang] ?? _content['en'] ?? _content['pt'] ?? const {};

  static List<Verse> allFor(String lang) {
    final data = _data(lang);
    final out = <Verse>[];
    for (final c in categories) {
      final list = data[c.id] ?? const [];
      for (var i = 0; i < list.length; i++) {
        out.add(Verse(c.id, i, list[i]));
      }
    }
    return out;
  }

  /// Todas as frases INTERCALADAS entre categorias (round-robin): card 1 de uma
  /// categoria, card 2 de outra... Evita centenas da mesma categoria (e mesma
  /// foto) em sequência na tela "Ver todas".
  static List<Verse> allInterleaved(String lang) {
    final data = _data(lang);
    final lists = <List<Verse>>[
      for (final c in categories)
        [
          for (var i = 0; i < (data[c.id]?.length ?? 0); i++)
            Verse(c.id, i, data[c.id]![i])
        ]
    ];
    final out = <Verse>[];
    var round = 0;
    var added = true;
    while (added) {
      added = false;
      for (final l in lists) {
        if (round < l.length) {
          out.add(l[round]);
          added = true;
        }
      }
      round++;
    }
    return out;
  }

  static List<Verse> byCategory(String lang, String id) {
    final list = _data(lang)[id] ?? const [];
    return [for (var i = 0; i < list.length; i++) Verse(id, i, list[i])];
  }

  static int countFor(String lang, String id) => (_data(lang)[id] ?? const []).length;

  static VerseCategory categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  static Verse? byId(String lang, String id) {
    final parts = id.split('#');
    if (parts.length != 2) return null;
    final cat = parts[0];
    final idx = int.tryParse(parts[1]);
    if (idx == null) return null;
    final list = _data(lang)[cat];
    if (list == null || idx < 0 || idx >= list.length) return null;
    return Verse(cat, idx, list[idx]);
  }

  /// Frase do dia — determinística por dia, no idioma pedido.
  static Verse ofToday(String lang) {
    final all = allFor(lang);
    if (all.isEmpty) return const Verse('motivacao', 0, '');
    final now = DateTime.now();
    final seed = now.year * 1000 + _dayOfYear(now);
    return all[seed % all.length];
  }

  /// Uma frase aleatória (botão "Nova frase").
  static Verse random(String lang) {
    final all = allFor(lang);
    if (all.isEmpty) return const Verse('motivacao', 0, '');
    final idx = DateTime.now().microsecondsSinceEpoch % all.length;
    return all[idx];
  }

  /// Frases variadas p/ o feed "Mais inspirações": uma de cada categoria
  /// DIFERENTE (girando por dia), para o feed não repetir o mesmo tema.
  static List<Verse> moreInspirations(String lang, {int count = 6}) {
    final today = ofToday(lang);
    final now = DateTime.now();
    final seed = now.year + _dayOfYear(now);
    final map = _data(lang);
    final out = <Verse>[];
    for (var i = 0; out.length < count && i < categories.length * 3; i++) {
      final cat = categories[(seed + i) % categories.length];
      final list = map[cat.id] ?? const [];
      if (list.isEmpty) continue;
      final idx = (seed * 7 + i * 13) % list.length;
      final id = '${cat.id}#$idx';
      if (id == today.id) continue;
      out.add(Verse(cat.id, idx, list[idx]));
    }
    return out;
  }

  static int _dayOfYear(DateTime d) =>
      d.difference(DateTime(d.year, 1, 1)).inDays;
}
