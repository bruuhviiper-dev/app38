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
  String get newVerse => _('newVerse');
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

  // Loja (remover anúncios)
  String get removeAdsTitle => _('removeAdsTitle');
  String get removeAdsHero => _('removeAdsHero');
  String get removeAdsDesc => _('removeAdsDesc');
  String get removeAdsCta => _('removeAdsCta');
  String get adsRemovedTitle => _('adsRemovedTitle');
  String get adsRemovedDesc => _('adsRemovedDesc');
  String get watchVideoAdFree => _('watchVideoAdFree');
  String get restorePurchase => _('restorePurchase');
  String get processing => _('processing');
  String get purchaseSuccess => _('purchaseSuccess');
  String get purchaseFailed => _('purchaseFailed');
  String get adFreeFor24h => _('adFreeFor24h');
  String get freeBenefitsTitle => _('freeBenefitsTitle');
  String get benefitThemes => _('benefitThemes');
  String get benefitEditor => _('benefitEditor');
  String get benefitContent => _('benefitContent');
  String get benefitOffline => _('benefitOffline');

  // Editor de imagem
  String get createImage => _('createImage');
  String get editImage => _('editImage');
  String get shareImage => _('shareImage');
  String get savedToGallery => _('savedToGallery');
  String get saveError => _('saveError');
  String get backgroundsLabel => _('backgroundsLabel');
  String get filtersLabel => _('filtersLabel');
  String get adjustmentsLabel => _('adjustmentsLabel');
  String get textLabel => _('textLabel');
  String get brightness => _('brightness');
  String get contrast => _('contrast');
  String get saturation => _('saturation');
  String get intensity => _('intensity');
  String get textSize => _('textSize');
  String get textColor => _('textColor');
  String get alignment => _('alignment');
  String get reset => _('reset');
  String get fmtStory => _('fmtStory');
  String get fmtFeed => _('fmtFeed');
  String get fmtStatus => _('fmtStatus');
  String get filterNone => _('filterNone');
  String get filterBlue => _('filterBlue');
  String get filterYellow => _('filterYellow');
  String get filterRed => _('filterRed');
  String get filterVintage => _('filterVintage');
  String get filterBW => _('filterBW');
  String get filterWarm => _('filterWarm');
  String get filterNoir => _('filterNoir');
  String get filterFade => _('filterFade');
  String get filterDrama => _('filterDrama');
  String get filterMint => _('filterMint');
  String get filterPurple => _('filterPurple');
  // Tipos de fundo do editor
  String get bgPhotos => _('bgPhotos');
  String get bgColors => _('bgColors');
  String get bgGradients => _('bgGradients');
  String get bgTextures => _('bgTextures');
  // Texturas
  String get texNone => _('texNone');
  String get texGrain => _('texGrain');
  String get texDots => _('texDots');
  String get texLines => _('texLines');
  String get texBokeh => _('texBokeh');
  String get texGlow => _('texGlow');
  String get texVignette => _('texVignette');

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
      'newVerse': 'Nova frase',
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
      'removeAdsTitle': 'Remover anúncios',
      'removeAdsHero': 'Use o app sem anúncios',
      'removeAdsDesc': 'Pagamento único, para sempre. Sem assinaturas.',
      'removeAdsCta': 'Remover anúncios',
      'adsRemovedTitle': 'Você já removeu os anúncios!',
      'adsRemovedDesc': 'Obrigado pelo apoio 🙏 Aproveite sem interrupções.',
      'watchVideoAdFree': 'Assistir vídeo (24h sem anúncios)',
      'restorePurchase': 'Restaurar compra',
      'processing': 'Processando…',
      'purchaseSuccess': 'Tudo certo! Anúncios removidos. 🎉',
      'purchaseFailed': 'Não foi possível concluir a compra.',
      'adFreeFor24h': 'Sem anúncios por 24 horas! ✨',
      'freeBenefitsTitle': 'TUDO ISTO É GRÁTIS',
      'benefitThemes': 'Tema claro e escuro',
      'benefitEditor': 'Editor de imagem com filtros',
      'benefitContent': 'Todas as categorias e frases',
      'benefitOffline': 'Funciona offline, no seu idioma',
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
      'adjustmentsLabel': 'Ajustes',
      'textLabel': 'Texto',
      'brightness': 'Brilho',
      'contrast': 'Contraste',
      'saturation': 'Saturação',
      'intensity': 'Intensidade',
      'textSize': 'Tamanho',
      'textColor': 'Cor',
      'alignment': 'Alinhamento',
      'reset': 'Resetar',
      'fmtStory': 'Story',
      'fmtFeed': 'Feed',
      'fmtStatus': 'Status',
      'filterNone': 'Original',
      'filterBlue': 'Azulado',
      'filterYellow': 'Amarelado',
      'filterRed': 'Avermelhado',
      'filterVintage': 'Vintage',
      'filterBW': 'P&B',
      'filterWarm': 'Quente',
      'filterNoir': 'Noir',
      'filterFade': 'Desbotado',
      'filterDrama': 'Drama',
      'filterMint': 'Menta',
      'filterPurple': 'Roxo',
      'bgPhotos': 'Fotos',
      'bgColors': 'Cores',
      'bgGradients': 'Degradês',
      'bgTextures': 'Texturas',
      'texNone': 'Nenhuma',
      'texGrain': 'Grão',
      'texDots': 'Pontos',
      'texLines': 'Linhas',
      'texBokeh': 'Bokeh',
      'texGlow': 'Brilho',
      'texVignette': 'Vinheta',
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
      'cat.superacao.name': 'Superação',
      'cat.superacao.desc': 'Força para seguir em frente',
      'cat.sucesso.name': 'Sucesso',
      'cat.sucesso.desc': 'Conquiste os seus objetivos',
      'cat.coragem.name': 'Coragem',
      'cat.coragem.desc': 'Enfrente com confiança',
      'cat.amizade.name': 'Amizade',
      'cat.amizade.desc': 'Quem caminha com você',
      'cat.gratidao.name': 'Gratidão',
      'cat.gratidao.desc': 'Reconhecer o bem',
      'cat.sabedoria.name': 'Sabedoria',
      'cat.sabedoria.desc': 'Aprender com a vida',
      'cat.paz.name': 'Paz',
      'cat.paz.desc': 'Serenidade para a alma',
      'cat.esperanca.name': 'Esperança',
      'cat.esperanca.desc': 'Acredite em dias melhores',
    },
    'en': {
      'app.name': 'Daily Quotes',
      'app.subtitle': 'Great thoughts for every day.',
      'notifications': 'Notifications',
      'verseOfDay': 'QUOTE OF THE DAY',
      'dailyInspiration': 'Daily inspiration',
      'share': 'Share',
      'save': 'Save',
      'newVerse': 'New quote',
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
      'removeAdsTitle': 'Remove ads',
      'removeAdsHero': 'Enjoy the app ad-free',
      'removeAdsDesc': 'One-time payment, forever. No subscriptions.',
      'removeAdsCta': 'Remove ads',
      'adsRemovedTitle': 'Ads already removed!',
      'adsRemovedDesc': 'Thanks for your support 🙏 Enjoy without interruptions.',
      'watchVideoAdFree': 'Watch a video (24h ad-free)',
      'restorePurchase': 'Restore purchase',
      'processing': 'Processing…',
      'purchaseSuccess': 'All set! Ads removed. 🎉',
      'purchaseFailed': 'Could not complete the purchase.',
      'adFreeFor24h': 'Ad-free for 24 hours! ✨',
      'freeBenefitsTitle': 'ALL OF THIS IS FREE',
      'benefitThemes': 'Light and dark theme',
      'benefitEditor': 'Image editor with filters',
      'benefitContent': 'All categories and quotes',
      'benefitOffline': 'Works offline, in your language',
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
      'adjustmentsLabel': 'Adjust',
      'textLabel': 'Text',
      'brightness': 'Brightness',
      'contrast': 'Contrast',
      'saturation': 'Saturation',
      'intensity': 'Intensity',
      'textSize': 'Size',
      'textColor': 'Color',
      'alignment': 'Alignment',
      'reset': 'Reset',
      'fmtStory': 'Story',
      'fmtFeed': 'Feed',
      'fmtStatus': 'Status',
      'filterNone': 'Original',
      'filterBlue': 'Cool',
      'filterYellow': 'Warm',
      'filterRed': 'Sunset',
      'filterVintage': 'Vintage',
      'filterBW': 'B&W',
      'filterWarm': 'Warm',
      'filterNoir': 'Noir',
      'filterFade': 'Fade',
      'filterDrama': 'Drama',
      'filterMint': 'Mint',
      'filterPurple': 'Purple',
      'bgPhotos': 'Photos',
      'bgColors': 'Colors',
      'bgGradients': 'Gradients',
      'bgTextures': 'Textures',
      'texNone': 'None',
      'texGrain': 'Grain',
      'texDots': 'Dots',
      'texLines': 'Lines',
      'texBokeh': 'Bokeh',
      'texGlow': 'Glow',
      'texVignette': 'Vignette',
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
      'cat.superacao.name': 'Resilience',
      'cat.superacao.desc': 'Strength to keep going',
      'cat.sucesso.name': 'Success',
      'cat.sucesso.desc': 'Reach your goals',
      'cat.coragem.name': 'Courage',
      'cat.coragem.desc': 'Face it with confidence',
      'cat.amizade.name': 'Friendship',
      'cat.amizade.desc': 'Those who walk with you',
      'cat.gratidao.name': 'Gratitude',
      'cat.gratidao.desc': 'Appreciate the good',
      'cat.sabedoria.name': 'Wisdom',
      'cat.sabedoria.desc': 'Learn from life',
      'cat.paz.name': 'Peace',
      'cat.paz.desc': 'Serenity for the soul',
      'cat.esperanca.name': 'Hope',
      'cat.esperanca.desc': 'Believe in better days',
    },
    'es': {
      'app.name': 'Frases del Día',
      'app.subtitle': 'Grandes pensamientos para cada día.',
      'notifications': 'Notificaciones',
      'verseOfDay': 'FRASE DEL DÍA',
      'dailyInspiration': 'Inspiración diaria',
      'share': 'Compartir',
      'save': 'Guardar',
      'newVerse': 'Nueva frase',
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
      'removeAdsTitle': 'Quitar anuncios',
      'removeAdsHero': 'Usa la app sin anuncios',
      'removeAdsDesc': 'Pago único, para siempre. Sin suscripciones.',
      'removeAdsCta': 'Quitar anuncios',
      'adsRemovedTitle': '¡Ya quitaste los anuncios!',
      'adsRemovedDesc': 'Gracias por tu apoyo 🙏 Disfruta sin interrupciones.',
      'watchVideoAdFree': 'Ver un video (24h sin anuncios)',
      'restorePurchase': 'Restaurar compra',
      'processing': 'Procesando…',
      'purchaseSuccess': '¡Listo! Anuncios quitados. 🎉',
      'purchaseFailed': 'No se pudo completar la compra.',
      'adFreeFor24h': '¡Sin anuncios por 24 horas! ✨',
      'freeBenefitsTitle': 'TODO ESTO ES GRATIS',
      'benefitThemes': 'Tema claro y oscuro',
      'benefitEditor': 'Editor de imagen con filtros',
      'benefitContent': 'Todas las categorías y frases',
      'benefitOffline': 'Funciona sin conexión, en tu idioma',
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
      'adjustmentsLabel': 'Ajustes',
      'textLabel': 'Texto',
      'brightness': 'Brillo',
      'contrast': 'Contraste',
      'saturation': 'Saturación',
      'intensity': 'Intensidad',
      'textSize': 'Tamaño',
      'textColor': 'Color',
      'alignment': 'Alineación',
      'reset': 'Restablecer',
      'fmtStory': 'Story',
      'fmtFeed': 'Feed',
      'fmtStatus': 'Status',
      'filterNone': 'Original',
      'filterBlue': 'Frío',
      'filterYellow': 'Cálido',
      'filterRed': 'Atardecer',
      'filterVintage': 'Vintage',
      'filterBW': 'B/N',
      'filterWarm': 'Cálido',
      'filterNoir': 'Noir',
      'filterFade': 'Desvaído',
      'filterDrama': 'Drama',
      'filterMint': 'Menta',
      'filterPurple': 'Púrpura',
      'bgPhotos': 'Fotos',
      'bgColors': 'Colores',
      'bgGradients': 'Degradados',
      'bgTextures': 'Texturas',
      'texNone': 'Ninguna',
      'texGrain': 'Grano',
      'texDots': 'Puntos',
      'texLines': 'Líneas',
      'texBokeh': 'Bokeh',
      'texGlow': 'Brillo',
      'texVignette': 'Viñeta',
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
      'cat.superacao.name': 'Superación',
      'cat.superacao.desc': 'Fuerza para seguir adelante',
      'cat.sucesso.name': 'Éxito',
      'cat.sucesso.desc': 'Alcanza tus metas',
      'cat.coragem.name': 'Valor',
      'cat.coragem.desc': 'Enfréntalo con confianza',
      'cat.amizade.name': 'Amistad',
      'cat.amizade.desc': 'Quien camina contigo',
      'cat.gratidao.name': 'Gratitud',
      'cat.gratidao.desc': 'Reconocer lo bueno',
      'cat.sabedoria.name': 'Sabiduría',
      'cat.sabedoria.desc': 'Aprender de la vida',
      'cat.paz.name': 'Paz',
      'cat.paz.desc': 'Serenidad para el alma',
      'cat.esperanca.name': 'Esperanza',
      'cat.esperanca.desc': 'Cree en días mejores',
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
