/// Fundos de paisagem (offline). Fotos reais do Unsplash — licença livre para
/// uso comercial (ver assets/landscapes/ATTRIBUTIONS.md). Organizados por TEMA
/// para o editor. Fallback elegante quando uma imagem não existir é tratado nos
/// widgets (gradiente navy + ícone).
class Landscapes {
  Landscapes._();

  static const _p = 'assets/landscapes/';

  static const hero = '${_p}hero_sunrise.jpg';
  static const onboarding = '${_p}onboarding.jpg';

  static const inspiration = <String>[
    '${_p}insp_peak.jpg',
    '${_p}insp_coast.jpg',
    '${_p}insp_lake.jpg',
  ];

  static String inspThumb(int i) => inspiration[i % inspiration.length];

  /// Fundos agrupados por TEMA (rótulo é chave de i18n `bgTheme.<key>`).
  static const themes = <String, List<String>>{
    'mountains': [
      '${_p}cat_motivacao.jpg',
      '${_p}insp_peak.jpg',
      '${_p}editor_bg03.jpg',
      '${_p}bg_mountains_cliff.jpg',
      '${_p}bg_misty_mountains.jpg',
      '${_p}bg_valley_sun.jpg',
    ],
    'sunrise': [
      hero,
      '${_p}cat_felicidade.jpg',
      '${_p}editor_bg04.jpg',
      '${_p}bg_sunrise_field.jpg',
      '${_p}bg_autumn.jpg',
    ],
    'forest': [
      '${_p}cat_reflexao.jpg',
      '${_p}cat_vida.jpg',
      '${_p}bg_misty_forest.jpg',
      '${_p}bg_green_hills.jpg',
    ],
    'water': [
      '${_p}cat_amor.jpg',
      '${_p}insp_coast.jpg',
      '${_p}insp_lake.jpg',
      '${_p}editor_bg05.jpg',
      '${_p}editor_bg06.jpg',
      '${_p}bg_calm_lake.jpg',
    ],
    'sky': [
      '${_p}editor_bg07.jpg',
      '${_p}editor_bg08.jpg',
      '${_p}onboarding.jpg',
    ],
    'city': [
      '${_p}cat_trabalho.jpg',
      '${_p}editor_bg01.jpg',
      '${_p}editor_bg02.jpg',
      '${_p}bg_city_geo.jpg',
      '${_p}bg_city_night.jpg',
    ],
  };

  /// Todos os fundos do EDITOR, na ordem dos temas (achatado).
  static final List<String> editorBackgrounds = [
    for (final list in themes.values) ...list,
  ];

  /// Índice (em [editorBackgrounds]) de um fundo que combina com a categoria.
  static int editorIndexForCategory(String categoryId) {
    final asset = '${_p}cat_$categoryId.jpg';
    final i = editorBackgrounds.indexOf(asset);
    return i < 0 ? 0 : i;
  }
}
