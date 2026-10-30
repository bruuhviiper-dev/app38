import 'package:flutter/material.dart';

/// Internacionalização da UI — pronta para 64 idiomas.
///
/// Arquitetura: um mapa `lang -> (chave -> texto)`. Hoje traz PT e EN; cada novo
/// idioma é só mais um mapa (ou um JSON por locale em `assets/l10n/`). A busca
/// faz fallback: idioma do aparelho -> inglês -> português -> a própria chave.
/// Assim nenhuma tela quebra enquanto as 64 traduções são preenchidas.
class T {
  const T(this.locale);
  final Locale locale;

  static T of(BuildContext context) =>
      Localizations.of<T>(context, T) ?? const T(Locale('en'));

  /// Código do idioma atual (para carregar o CONTEÚDO por locale).
  String get lang => locale.languageCode;

  /// Nome do app — traduzido por idioma (ver `app.name`).
  String get appName => _('app.name');

  String _(String key) {
    final lang = locale.languageCode;
    return _data[lang]?[key] ?? _data['en']![key] ?? _data['pt']![key] ?? key;
  }

  // Cabeçalho
  String get appSubtitle => _('app.subtitle');
  String get notifications => _('notifications');

  // Frase do dia
  String get verseOfDay => _('verseOfDay');
  String get dailyInspiration => _('dailyInspiration');
  String get share => _('share');
  String get save => _('save');
  String get savedToFavorites => _('savedToFavorites');
  String get removedFromFavorites => _('removedFromFavorites');

  // Seções
  String get exploreByCategory => _('exploreByCategory');
  String get seeAll => _('seeAll');
  String get moreInspirations => _('moreInspirations');

  // Navegação
  String get navHome => _('navHome');
  String get navExplore => _('navExplore');
  String get navFavorites => _('navFavorites');
  String get navSettings => _('navSettings');
  String get navCategories => _('navCategories');
  String get navMore => _('navMore');

  // Categorias
  String get categoriesTitle => _('categoriesTitle');
  String get filterAll => _('filterAll');
  String get filterPopular => _('filterPopular');
  String get filterNew => _('filterNew');
  String versesCount(int n) =>
      '$n ${_(n == 1 ? 'verse.one' : 'verse.many')}';

  // Detalhe
  String get copy => _('copy');
  String get copied => _('copied');
  String get favorite => _('favorite');

  // Notificação (texto GENÉRICO — nunca revela a frase)
  String get notifBody => _('notifBody');

  // Editor de imagem
  String get createImage => _('createImage');
  String get editImage => _('editImage');
  String get shareImage => _('shareImage');
  String get savedToGallery => _('savedToGallery');
  String get saveError => _('saveError');
  String get backgroundsLabel => _('backgroundsLabel');
  String get filtersLabel => _('filtersLabel');
  String get filterNone => _('filterNone');
  String get filterBlue => _('filterBlue');
  String get filterYellow => _('filterYellow');
  String get filterRed => _('filterRed');
  String get filterVintage => _('filterVintage');
  String get filterBW => _('filterBW');

  // Favoritos
  String get favoritesTitle => _('favoritesTitle');
  String get favText => _('favText');
  String get favByCategory => _('favByCategory');
  String get emptyFavorites => _('emptyFavorites');
  String get emptyFavoritesHint => _('emptyFavoritesHint');

  // Pesquisa
  String get searchTitle => _('searchTitle');
  String get searchHint => _('searchHint');
  String get popularSuggestions => _('popularSuggestions');
  String get results => _('results');
  String get searchPrompt => _('searchPrompt');
  String noResults(String q) => _('noResults').replaceFirst('{q}', q);

  // Configurações
  String get settingsTitle => _('settingsTitle');
  String get language => _('language');
  String get systemDefault => _('systemDefault');
  String get notificationsLabel => _('notificationsLabel');
  String get notificationsDesc => _('notificationsDesc');
  String get theme => _('theme');
  String get themeSystem => _('themeSystem');
  String get themeLight => _('themeLight');
  String get themeDark => _('themeDark');
  String get fontSize => _('fontSize');
  String get fontSmall => _('fontSmall');
  String get fontDefault => _('fontDefault');
  String get fontLarge => _('fontLarge');
  String get about => _('about');
  String get shareApp => _('shareApp');
  String get rateApp => _('rateApp');
  String get privacy => _('privacy');
  String get terms => _('terms');
  String get version => _('version');
  String get preferences => _('preferences');
  String get general => _('general');

  // Onboarding
  String get onbSubtitle => _('onbSubtitle');
  String get onbSub2 => _('onbSub2');
  String get onbSub3 => _('onbSub3');
  String get skip => _('skip');
  String get start => _('start');
  String get next => _('next');
  String get splashTagline => _('app.subtitle');

  // Estados
  String get loading => _('loading');
  String get emptyVerses => _('emptyVerses');
  String get errorLoading => _('errorLoading');
  String get retry => _('retry');
  String get comingSoon => _('comingSoon');

  // Categorias (resolvidas por id)
  String catName(String id) => _('cat.$id.name');
  String catDesc(String id) => _('cat.$id.desc');

  static const Map<String, Map<String, String>> _data = {
    'pt': {
      'app.name': 'Frases Diárias',
      'app.subtitle': 'Grandes pensamentos para todos os dias.',
      'notifications': 'Notificações',
      'verseOfDay': 'FRASE DO DIA',
      'dailyInspiration': 'Inspiração diária',
      'share': 'Compartilhar',
      'save': 'Salvar',
      'savedToFavorites': 'Salvo nos favoritos',
      'removedFromFavorites': 'Removido dos favoritos',
      'exploreByCategory': 'Explore por categoria',
      'seeAll': 'Ver todas',
      'moreInspirations': 'Mais inspirações',
      'navHome': 'Início',
      'navExplore': 'Explorar',
      'navFavorites': 'Favoritos',
      'navSettings': 'Ajustes',
      'navCategories': 'Categorias',
      'navMore': 'Mais',
      'categoriesTitle': 'Categorias',
      'filterAll': 'Todas',
      'filterPopular': 'Mais populares',
      'filterNew': 'Novas',
      'verse.one': 'frase',
      'verse.many': 'frases',
      'notifBody': 'Toque para ver a sua frase de hoje 🌅',
      'copy': 'Copiar',
      'copied': 'Frase copiada',
      'favorite': 'Favoritar',
      'createImage': 'Criar imagem',
      'editImage': 'Editar',
      'shareImage': 'Compartilhar imagem',
      'savedToGallery': 'Imagem salva na galeria',
      'saveError': 'Não foi possível salvar a imagem',
      'backgroundsLabel': 'Fundo',
      'filtersLabel': 'Filtros',
      'filterNone': 'Original',
      'filterBlue': 'Azulado',
      'filterYellow': 'Amarelado',
      'filterRed': 'Avermelhado',
      'filterVintage': 'Vintage',
      'filterBW': 'P&B',
      'favoritesTitle': 'Favoritos',
      'favText': 'Texto',
      'favByCategory': 'Por categoria',
      'emptyFavorites': 'Você ainda não salvou nenhuma frase.',
      'emptyFavoritesHint': 'Toque no coração para guardar as que mais gostar.',
      'searchTitle': 'Buscar',
      'searchHint': 'Digite uma palavra-chave...',
      'popularSuggestions': 'Sugestões populares',
      'results': 'Resultados',
      'searchPrompt': 'Pesquise por tema, palavra ou categoria.',
      'noResults': 'Nenhum resultado para "{q}".',
      'settingsTitle': 'Configurações',
      'language': 'Idioma',
      'systemDefault': 'Padrão do sistema',
      'notificationsLabel': 'Notificações',
      'notificationsDesc': 'Receba uma inspiração por dia',
      'theme': 'Tema',
      'themeSystem': 'Automático',
      'themeLight': 'Claro',
      'themeDark': 'Escuro',
      'fontSize': 'Tamanho da fonte',
      'fontSmall': 'Pequeno',
      'fontDefault': 'Padrão',
      'fontLarge': 'Grande',
      'about': 'Sobre o app',
      'shareApp': 'Compartilhar app',
      'rateApp': 'Avaliar na Play Store',
      'privacy': 'Política de Privacidade',
      'terms': 'Termos de Uso',
      'version': 'Versão',
      'preferences': 'PREFERÊNCIAS',
      'general': 'GERAL',
      'onbSubtitle':
          'Inspire-se todos os dias com mensagens que fazem a diferença.',
      'onbSub2':
          'Salve as suas favoritas e compartilhe com quem você ama.',
      'onbSub3': 'Leve, rápido e no seu idioma — e funciona offline.',
      'skip': 'Pular',
      'start': 'Começar',
      'next': 'Avançar',
      'loading': 'Carregando...',
      'emptyVerses': 'Nenhuma frase disponível ainda.',
      'errorLoading': 'Não foi possível carregar o conteúdo.',
      'retry': 'Tentar de novo',
      'comingSoon': 'Em breve',
      'cat.motivacao.name': 'Motivação',
      'cat.motivacao.desc': 'Força para continuar',
      'cat.amor.name': 'Amor',
      'cat.amor.desc': 'Palavras que aproximam',
      'cat.reflexao.name': 'Reflexão',
      'cat.reflexao.desc': 'Um momento para pensar',
      'cat.felicidade.name': 'Felicidade',
      'cat.felicidade.desc': 'Mais leveza no seu dia',
      'cat.vida.name': 'Vida',
      'cat.vida.desc': 'Viva o agora',
      'cat.trabalho.name': 'Trabalho',
      'cat.trabalho.desc': 'Foco e sucesso',
    },
    'en': {
      'app.name': 'Daily Quotes',
      'app.subtitle': 'Great thoughts for every day.',
      'notifications': 'Notifications',
      'verseOfDay': 'QUOTE OF THE DAY',
      'dailyInspiration': 'Daily inspiration',
      'share': 'Share',
      'save': 'Save',
      'savedToFavorites': 'Saved to favorites',
      'removedFromFavorites': 'Removed from favorites',
      'exploreByCategory': 'Explore by category',
      'seeAll': 'See all',
      'moreInspirations': 'More inspirations',
      'navHome': 'Home',
      'navExplore': 'Explore',
      'navFavorites': 'Favorites',
      'navSettings': 'Settings',
      'navCategories': 'Categories',
      'navMore': 'More',
      'categoriesTitle': 'Categories',
      'filterAll': 'All',
      'filterPopular': 'Most popular',
      'filterNew': 'New',
      'verse.one': 'quote',
      'verse.many': 'quotes',
      'notifBody': 'Tap to see your quote for today 🌅',
      'copy': 'Copy',
      'copied': 'Quote copied',
      'favorite': 'Favorite',
      'createImage': 'Create image',
      'editImage': 'Edit',
      'shareImage': 'Share image',
      'savedToGallery': 'Image saved to gallery',
      'saveError': "Couldn't save the image",
      'backgroundsLabel': 'Background',
      'filtersLabel': 'Filters',
      'filterNone': 'Original',
      'filterBlue': 'Cool',
      'filterYellow': 'Warm',
      'filterRed': 'Sunset',
      'filterVintage': 'Vintage',
      'filterBW': 'B&W',
      'favoritesTitle': 'Favorites',
      'favText': 'Text',
      'favByCategory': 'By category',
      'emptyFavorites': "You haven't saved any quotes yet.",
      'emptyFavoritesHint': 'Tap the heart to keep the ones you love.',
      'searchTitle': 'Search',
      'searchHint': 'Type a keyword...',
      'popularSuggestions': 'Popular suggestions',
      'results': 'Results',
      'searchPrompt': 'Search by theme, word or category.',
      'noResults': 'No results for "{q}".',
      'settingsTitle': 'Settings',
      'language': 'Language',
      'systemDefault': 'System default',
      'notificationsLabel': 'Notifications',
      'notificationsDesc': 'Get a daily dose of inspiration',
      'theme': 'Theme',
      'themeSystem': 'Automatic',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'fontSize': 'Font size',
      'fontSmall': 'Small',
      'fontDefault': 'Default',
      'fontLarge': 'Large',
      'about': 'About',
      'shareApp': 'Share app',
      'rateApp': 'Rate on Play Store',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Use',
      'version': 'Version',
      'preferences': 'PREFERENCES',
      'general': 'GENERAL',
      'onbSubtitle': 'Get inspired every day with messages that make a difference.',
      'onbSub2': 'Save your favorites and share them with the people you love.',
      'onbSub3': 'Light, fast and in your language — and it works offline.',
      'skip': 'Skip',
      'start': 'Get started',
      'next': 'Next',
      'loading': 'Loading...',
      'emptyVerses': 'No quotes available yet.',
      'errorLoading': 'We could not load the content.',
      'retry': 'Try again',
      'comingSoon': 'Coming soon',
      'cat.motivacao.name': 'Motivation',
      'cat.motivacao.desc': 'Strength to keep going',
      'cat.amor.name': 'Love',
      'cat.amor.desc': 'Words that bring us closer',
      'cat.reflexao.name': 'Reflection',
      'cat.reflexao.desc': 'A moment to think',
      'cat.felicidade.name': 'Happiness',
      'cat.felicidade.desc': 'More lightness in your day',
      'cat.vida.name': 'Life',
      'cat.vida.desc': 'Live the now',
      'cat.trabalho.name': 'Work',
      'cat.trabalho.desc': 'Focus and success',
    },
    'es': {
      'app.name': 'Frases del Día',
      'app.subtitle': 'Grandes pensamientos para cada día.',
      'notifications': 'Notificaciones',
      'verseOfDay': 'FRASE DEL DÍA',
      'dailyInspiration': 'Inspiración diaria',
      'share': 'Compartir',
      'save': 'Guardar',
      'savedToFavorites': 'Guardado en favoritos',
      'removedFromFavorites': 'Quitado de favoritos',
      'exploreByCategory': 'Explora por categoría',
      'seeAll': 'Ver todas',
      'moreInspirations': 'Más inspiraciones',
      'navHome': 'Inicio',
      'navExplore': 'Explorar',
      'navFavorites': 'Favoritos',
      'navSettings': 'Ajustes',
      'navCategories': 'Categorías',
      'navMore': 'Más',
      'categoriesTitle': 'Categorías',
      'filterAll': 'Todas',
      'filterPopular': 'Más populares',
      'filterNew': 'Nuevas',
      'verse.one': 'frase',
      'verse.many': 'frases',
      'notifBody': 'Toca para ver tu frase de hoy 🌅',
      'copy': 'Copiar',
      'copied': 'Frase copiada',
      'favorite': 'Favorito',
      'createImage': 'Crear imagen',
      'editImage': 'Editar',
      'shareImage': 'Compartir imagen',
      'savedToGallery': 'Imagen guardada en la galería',
      'saveError': 'No se pudo guardar la imagen',
      'backgroundsLabel': 'Fondo',
      'filtersLabel': 'Filtros',
      'filterNone': 'Original',
      'filterBlue': 'Frío',
      'filterYellow': 'Cálido',
      'filterRed': 'Atardecer',
      'filterVintage': 'Vintage',
      'filterBW': 'B/N',
      'favoritesTitle': 'Favoritos',
      'favText': 'Texto',
      'favByCategory': 'Por categoría',
      'emptyFavorites': 'Aún no has guardado ninguna frase.',
      'emptyFavoritesHint': 'Toca el corazón para guardar las que más te gusten.',
      'searchTitle': 'Buscar',
      'searchHint': 'Escribe una palabra clave...',
      'popularSuggestions': 'Sugerencias populares',
      'results': 'Resultados',
      'searchPrompt': 'Busca por tema, palabra o categoría.',
      'noResults': 'Sin resultados para "{q}".',
      'settingsTitle': 'Ajustes',
      'language': 'Idioma',
      'systemDefault': 'Predeterminado del sistema',
      'notificationsLabel': 'Notificaciones',
      'notificationsDesc': 'Recibe una inspiración cada día',
      'theme': 'Tema',
      'themeSystem': 'Automático',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'fontSize': 'Tamaño de fuente',
      'fontSmall': 'Pequeño',
      'fontDefault': 'Normal',
      'fontLarge': 'Grande',
      'about': 'Acerca de',
      'shareApp': 'Compartir app',
      'rateApp': 'Valorar en Play Store',
      'privacy': 'Política de Privacidad',
      'terms': 'Términos de Uso',
      'version': 'Versión',
      'preferences': 'PREFERENCIAS',
      'general': 'GENERAL',
      'onbSubtitle': 'Inspírate cada día con mensajes que marcan la diferencia.',
      'onbSub2': 'Guarda tus favoritas y compártelas con quien amas.',
      'onbSub3': 'Ligera, rápida y en tu idioma — y funciona sin conexión.',
      'skip': 'Saltar',
      'start': 'Empezar',
      'next': 'Siguiente',
      'loading': 'Cargando...',
      'emptyVerses': 'Aún no hay frases disponibles.',
      'errorLoading': 'No se pudo cargar el contenido.',
      'retry': 'Reintentar',
      'comingSoon': 'Próximamente',
      'cat.motivacao.name': 'Motivación',
      'cat.motivacao.desc': 'Fuerza para continuar',
      'cat.amor.name': 'Amor',
      'cat.amor.desc': 'Palabras que acercan',
      'cat.reflexao.name': 'Reflexión',
      'cat.reflexao.desc': 'Un momento para pensar',
      'cat.felicidade.name': 'Felicidad',
      'cat.felicidade.desc': 'Más ligereza en tu día',
      'cat.vida.name': 'Vida',
      'cat.vida.desc': 'Vive el ahora',
      'cat.trabalho.name': 'Trabajo',
      'cat.trabalho.desc': 'Enfoque y éxito',
    },
  };

  /// Os 64 idiomas-alvo da publicação. A UI aceita todos; os que ainda não
  /// têm mapa em [_data] caem no inglês automaticamente (sem quebrar layout).
  static const List<String> targetLanguages = [
    'pt', 'en', 'es', 'fr', 'de', 'it', 'nl', 'pl', 'ru', 'uk', 'tr', 'ar',
    'fa', 'he', 'hi', 'bn', 'ur', 'ta', 'te', 'mr', 'gu', 'kn', 'ml', 'pa',
    'id', 'ms', 'th', 'vi', 'fil', 'ja', 'ko', 'zh', 'zh_TW', 'my', 'km',
    'si', 'ne', 'sw', 'am', 'ha', 'yo', 'zu', 'af', 'sq', 'az', 'be', 'bg',
    'hr', 'cs', 'da', 'et', 'fi', 'el', 'hu', 'is', 'ka', 'kk', 'lv', 'lt',
    'ro', 'sr', 'sk', 'sl', 'sv',
  ];

  static List<Locale> get supportedLocales => [
        for (final code in targetLanguages)
          code.contains('_')
              ? Locale(code.split('_')[0], code.split('_')[1])
              : Locale(code),
      ];

  /// Resolve o locale do aparelho para um dos suportados (fallback inglês).
  static Locale resolve(Locale? device, Iterable<Locale> supported) {
    if (device == null) return const Locale('en');
    for (final l in supported) {
      if (l.languageCode == device.languageCode) return l;
    }
    return const Locale('en');
  }
}

/// Delegate que injeta [T] na árvore via Localizations.
class TDelegate extends LocalizationsDelegate<T> {
  const TDelegate();

  @override
  bool isSupported(Locale locale) =>
      T.targetLanguages.any((c) => c.split('_')[0] == locale.languageCode);

  @override
  Future<T> load(Locale locale) async => T(locale);

  @override
  bool shouldReload(TDelegate old) => false;
}
