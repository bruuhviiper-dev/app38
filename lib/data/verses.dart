import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Uma frase resolvida para um idioma. O [id] (`categoria#índice`) é ESTÁVEL
/// entre idiomas — assim os favoritos funcionam mesmo trocando a língua, e o
/// texto é mostrado no idioma atual.
class Verse {
  const Verse(this.categoryId, this.index, this.text);
  final String categoryId;
  final int index;
  final String text;

  String get id => '$categoryId#$index';
}

/// Metadados de categoria. [id] é a chave de i18n (`cat.<id>.name`/`.desc`).
class VerseCategory {
  const VerseCategory(this.id, this.icon, this.asset);
  final String id;
  final IconData icon;
  final String asset;
}

/// Banco local de frases, por IDIOMA (conteúdo paralelo PT/EN — mesmo número por
/// categoria, então o `índice` mapeia entre línguas). Idiomas sem conteúdo caem
/// no inglês. A UI já é 100% internacionalizada; aqui é o CONTEÚDO.
class VerseData {
  VerseData._();

  static const categories = <VerseCategory>[
    VerseCategory('motivacao', LucideIcons.mountain,
        'assets/landscapes/cat_motivacao.jpg'),
    VerseCategory('amor', LucideIcons.heart, 'assets/landscapes/cat_amor.jpg'),
    VerseCategory('reflexao', LucideIcons.feather,
        'assets/landscapes/cat_reflexao.jpg'),
    VerseCategory('felicidade', LucideIcons.sun,
        'assets/landscapes/cat_felicidade.jpg'),
    VerseCategory('vida', LucideIcons.sprout, 'assets/landscapes/cat_vida.jpg'),
    VerseCategory('trabalho', LucideIcons.briefcase,
        'assets/landscapes/cat_trabalho.jpg'),
  ];

  static const _content = <String, Map<String, List<String>>>{
    'pt': {
      'motivacao': [
        'Cada novo dia é uma oportunidade para recomeçar.',
        'Sonhe, planeje e faça: o futuro se constrói hoje.',
        'Pequenos passos também levam a grandes conquistas.',
        'Acredite no seu potencial e dê o primeiro passo.',
        'A persistência transforma o impossível em conquista.',
        'Comece de onde você está, com o que você tem.',
        'Sua única concorrência é quem você foi ontem.',
        'Coragem não é a ausência de medo, é agir apesar dele.',
      ],
      'amor': [
        'Ame de verdade e o resto encontra o seu lugar.',
        'O amor se revela nos pequenos gestos de cada dia.',
        'Onde há amor, há sempre um recomeço possível.',
        'Amar é caminhar lado a lado, no mesmo ritmo.',
        'O cuidado é a linguagem mais sincera do amor.',
        'Perto de quem se ama, até o silêncio é bom.',
        'O amor não procura o perfeito; cuida do real.',
        'Amar bem começa por amar a si mesmo.',
      ],
      'reflexao': [
        'A vida fica mais leve quando você valoriza o essencial.',
        'Respire: nem tudo precisa de resposta agora.',
        'O que te incomoda hoje pode te ensinar amanhã.',
        'A paz começa quando você aceita o que não pode mudar.',
        'Silencie o ruído e escute o que o coração diz.',
        'Viver bem é saber o peso certo de cada coisa.',
        'Às vezes, desacelerar é a forma mais rápida de chegar.',
        'O tempo que você dedica a pensar nunca é perdido.',
      ],
      'felicidade': [
        'A felicidade mora nas coisas simples do dia a dia.',
        'Sorria: há motivos bons mesmo nos dias comuns.',
        'Gratidão é o atalho mais curto para a alegria.',
        'Colecione momentos, não motivos para reclamar.',
        'Ser feliz é uma escolha que se faz todos os dias.',
        'A leveza também é uma forma de coragem.',
        'Encontre beleza no agora; é tudo o que existe.',
        'Quem agradece o pouco, multiplica o muito.',
      ],
      'vida': [
        'Viva o agora: o presente é o único tempo real.',
        'A vida é feita de recomeços; permita-se tentar de novo.',
        'Cada estação tem a sua beleza. Aproveite a sua.',
        'Cresça no seu tempo, como tudo o que é vivo.',
        'A vida recompensa quem não desiste no meio do caminho.',
        'Faça da sua jornada algo que valha a pena contar.',
        'O melhor dia para começar sempre foi hoje.',
        'A vida floresce fora da zona de conforto.',
      ],
      'trabalho': [
        'Foco no essencial: feito é melhor que perfeito.',
        'Disciplina leva você aonde a motivação não alcança.',
        'Grandes carreiras se constroem um dia de cada vez.',
        'Trabalhe pelos seus sonhos, não só pelos dos outros.',
        'A qualidade do seu foco define a do resultado.',
        'Progresso vale mais que pressa.',
        'Faça o simples bem feito e repita todos os dias.',
        'Talento abre portas; o esforço as mantém abertas.',
      ],
    },
    'en': {
      'motivacao': [
        'Every new day is a fresh chance to begin again.',
        'Dream it, plan it, do it — the future is built today.',
        'Small steps still lead to great achievements.',
        'Believe in your potential and take the first step.',
        'Persistence turns the impossible into done.',
        'Start where you are, with what you have.',
        'Your only competition is who you were yesterday.',
        "Courage isn't the absence of fear — it's acting anyway.",
      ],
      'amor': [
        'Love truly and everything else finds its place.',
        'Love shows itself in the small gestures of each day.',
        'Where there is love, a new beginning is always possible.',
        'To love is to walk side by side, in the same rhythm.',
        'Care is the most honest language of love.',
        'Next to the one you love, even silence feels good.',
        "Love doesn't seek the perfect; it tends the real.",
        'Loving well begins with loving yourself.',
      ],
      'reflexao': [
        'Life gets lighter when you value what truly matters.',
        'Breathe — not everything needs an answer right now.',
        'What troubles you today may teach you tomorrow.',
        "Peace begins when you accept what you can't change.",
        'Quiet the noise and listen to what your heart says.',
        'Living well is knowing the right weight of each thing.',
        'Sometimes slowing down is the fastest way to arrive.',
        'Time spent thinking is never time wasted.',
      ],
      'felicidade': [
        'Happiness lives in the simple things of every day.',
        'Smile — there are good reasons even in ordinary days.',
        'Gratitude is the shortest path to joy.',
        'Collect moments, not reasons to complain.',
        'Being happy is a choice you make every day.',
        'Lightness is a form of courage too.',
        "Find beauty in now; it's all there is.",
        'Those who are thankful for little multiply the much.',
      ],
      'vida': [
        'Live now — the present is the only real time.',
        'Life is made of fresh starts; let yourself try again.',
        'Every season has its beauty. Enjoy yours.',
        'Grow at your own pace, like everything alive.',
        "Life rewards those who don't quit halfway.",
        'Make your journey a story worth telling.',
        'The best day to begin has always been today.',
        'Life blooms outside the comfort zone.',
      ],
      'trabalho': [
        'Focus on what matters: done is better than perfect.',
        "Discipline takes you where motivation can't.",
        'Great careers are built one day at a time.',
        "Work for your dreams, not only for others'.",
        'The quality of your focus sets the quality of the result.',
        'Progress is worth more than haste.',
        'Do the simple thing well and repeat it every day.',
        'Talent opens doors; effort keeps them open.',
      ],
    },
  };

  /// Idiomas com conteúdo próprio (os demais usam o inglês).
  static bool hasContent(String lang) => _content.containsKey(lang);

  static Map<String, List<String>> _data(String lang) =>
      _content[lang] ?? _content['en']!;

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

  static List<Verse> byCategory(String lang, String id) {
    final list = _data(lang)[id] ?? const [];
    return [for (var i = 0; i < list.length; i++) Verse(id, i, list[i])];
  }

  static VerseCategory categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  /// Resolve um id estável (`cat#idx`) para o texto no idioma atual.
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
    final now = DateTime.now();
    final seed = now.year * 1000 + _dayOfYear(now);
    return all[seed % all.length];
  }

  /// Algumas frases para "Mais inspirações" (exclui a frase do dia).
  static List<Verse> moreInspirations(String lang, {int count = 6}) {
    final today = ofToday(lang);
    final list = allFor(lang).where((v) => v.id != today.id).toList();
    if (list.isEmpty) return const [];
    final now = DateTime.now();
    final start = (now.year + _dayOfYear(now)) % list.length;
    return [for (var i = 0; i < count; i++) list[(start + i) % list.length]];
  }

  static int _dayOfYear(DateTime d) =>
      d.difference(DateTime(d.year, 1, 1)).inDays;
}
