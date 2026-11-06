// Testes de dados + i18n. O conteúdo vem de assets/frases/<lang>.json (carregado
// via VerseData.init). i18n é puro. O app completo roda no device.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frases_diarias/data/verses.dart';
import 'package:frases_diarias/l10n/strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await VerseData.init();
  });

  test('14 categorias; cada frase pertence a uma delas (pt)', () {
    expect(VerseData.categories.length, 14);
    final ids = VerseData.categories.map((c) => c.id).toSet();
    for (final v in VerseData.allFor('pt')) {
      expect(ids.contains(v.categoryId), isTrue);
    }
  });

  test('pelo menos 5000 frases por idioma (pt/en/es)', () {
    expect(VerseData.allFor('pt').length, greaterThanOrEqualTo(5000));
    expect(VerseData.allFor('en').length, greaterThanOrEqualTo(5000));
    expect(VerseData.allFor('es').length, greaterThanOrEqualTo(5000));
  });

  test('conteúdo pt/en/es paralelo (mesmo nº por categoria; ids estáveis)', () {
    for (final c in VerseData.categories) {
      final pt = VerseData.countFor('pt', c.id);
      expect(VerseData.countFor('en', c.id), pt, reason: c.id);
      expect(VerseData.countFor('es', c.id), pt, reason: c.id);
    }
  });

  test('byId resolve o mesmo slot em idiomas diferentes', () {
    final ptVerse = VerseData.allFor('pt').first;
    final enVerse = VerseData.byId('en', ptVerse.id);
    expect(enVerse, isNotNull);
    expect(enVerse!.id, ptVerse.id);
    expect(enVerse.text, isNot(ptVerse.text));
  });

  test('frase do dia determinística; idioma sem conteúdo cai no inglês', () {
    expect(VerseData.ofToday('pt').id, VerseData.ofToday('pt').id);
    expect(VerseData.hasContent('fr'), isFalse);
    expect(VerseData.allFor('fr').first.text, VerseData.allFor('en').first.text);
  });

  test('i18n: nome do app + categorias por idioma', () {
    const pt = T(Locale('pt'));
    const en = T(Locale('en'));
    const es = T(Locale('es'));
    expect(pt.appName, 'Frases Diárias');
    expect(en.appName, 'Daily Quotes');
    expect(es.appName, 'Frases del Día');
    expect(pt.catName('esperanca'), 'Esperança');
    expect(en.catName('gratidao'), 'Gratitude');
    expect(es.catName('sabedoria'), 'Sabiduría');
  });
}
