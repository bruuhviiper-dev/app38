/// Caminhos dos fundos de paisagem (offline). Fallback elegante quando uma
/// imagem não existir é tratado nos widgets (gradiente navy + ícone).
class Landscapes {
  Landscapes._();

  static const hero = 'assets/landscapes/hero_sunrise.jpg';
  static const onboarding = 'assets/landscapes/onboarding.jpg';

  static const inspiration = <String>[
    'assets/landscapes/insp_peak.jpg',
    'assets/landscapes/insp_coast.jpg',
    'assets/landscapes/insp_lake.jpg',
  ];

  static String inspThumb(int i) => inspiration[i % inspiration.length];

  /// Repositório de fundos do EDITOR de imagem (18 paisagens reais, offline).
  static const editorBackgrounds = <String>[
    hero,
    'assets/landscapes/cat_motivacao.jpg',
    'assets/landscapes/cat_amor.jpg',
    'assets/landscapes/cat_reflexao.jpg',
    'assets/landscapes/cat_felicidade.jpg',
    'assets/landscapes/cat_vida.jpg',
    'assets/landscapes/cat_trabalho.jpg',
    'assets/landscapes/insp_peak.jpg',
    'assets/landscapes/insp_coast.jpg',
    'assets/landscapes/insp_lake.jpg',
    'assets/landscapes/editor_bg01.jpg',
    'assets/landscapes/editor_bg02.jpg',
    'assets/landscapes/editor_bg03.jpg',
    'assets/landscapes/editor_bg04.jpg',
    'assets/landscapes/editor_bg05.jpg',
    'assets/landscapes/editor_bg06.jpg',
    'assets/landscapes/editor_bg07.jpg',
    'assets/landscapes/editor_bg08.jpg',
  ];

  /// Índice do fundo que combina com uma categoria (para pré-selecionar).
  static int editorIndexForCategory(String categoryId) {
    final asset = 'assets/landscapes/cat_$categoryId.jpg';
    final i = editorBackgrounds.indexOf(asset);
    return i < 0 ? 0 : i;
  }
}
