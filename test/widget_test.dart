// Testes da camada de dados + i18n. O app completo depende de SharedPreferences
// na inicialização, então os testes de widget rodam no device; aqui garantimos
// a lógica pura (frase do dia, categorias, conteúdo por idioma, i18n).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frases_diarias/data/verses.dart';
import 'package:frases_diarias/l10n/strings.dart';

void main() {
  test('frase do dia é determinística no mesmo dia', () {
    final a = VerseData.ofToday('pt');
    final b = VerseData.ofToday('pt');
    expect(a.id, b.id);
    expect(VerseData.allFor('pt'), isNotEmpty);
  });

  test('há 6 categorias e cada frase pertence a uma delas', () {
    expect(VerseData.categories.length, 6);
    final ids = VerseData.categories.map((c) => c.id).toSet();
    for (final v in VerseData.allFor('pt')) {
      expect(ids.contains(v.categoryId), isTrue);
    }
  });

  test('conteúdo PT e EN têm o mesmo nº de frases por categoria (ids estáveis)',
      () {
    for (final c in VerseData.categories) {
      expect(VerseData.byCategory('pt', c.id).length,
          VerseData.byCategory('en', c.id).length,
          reason: 'categoria ${c.id}');
    }
  });

  test('byId resolve o mesmo slot em idiomas diferentes', () {
    final ptVerse = VerseData.allFor('pt').first;
    final enVerse = VerseData.byId('en', ptVerse.id);
    expect(enVerse, isNotNull);
    expect(enVerse!.id, ptVerse.id);
    expect(enVerse.text, isNot(ptVerse.text)); // texto traduzido
  });

  test('idioma sem conteúdo cai no inglês', () {
    expect(VerseData.hasContent('fr'), isFalse);
    expect(VerseData.allFor('fr').first.text,
        VerseData.allFor('en').first.text);
  });

  test('mais inspirações não repete a frase do dia', () {
    final today = VerseData.ofToday('en');
    final more = VerseData.moreInspirations('en', count: 6);
    expect(more.any((v) => v.id == today.id), isFalse);
  });

  test('i18n: nome do app e rótulos por idioma', () {
    const pt = T(Locale('pt'));
    const en = T(Locale('en'));
    expect(pt.appName, 'Frases Diárias');
    expect(en.appName, 'Daily Quotes');
    expect(pt.verseOfDay, 'FRASE DO DIA');
    expect(en.verseOfDay, 'QUOTE OF THE DAY');
  });

  test('Espanhol: UI + conteúdo próprios', () {
    const es = T(Locale('es'));
    expect(VerseData.hasContent('es'), isTrue);
    expect(es.appName, 'Frases del Día');
    expect(es.verseOfDay, 'FRASE DEL DÍA');
    expect(es.navHome, 'Inicio');
    expect(es.catName('motivacao'), 'Motivación');
    // conteúdo ES com 8 por categoria e diferente do inglês
    for (final c in VerseData.categories) {
      expect(VerseData.byCategory('es', c.id).length, 8, reason: c.id);
    }
    final esFirst = VerseData.allFor('es').first.text;
    final enFirst = VerseData.allFor('en').first.text;
    expect(esFirst, isNot(enFirst));
    expect(esFirst.contains('oportunidad'), isTrue);
  });
}
